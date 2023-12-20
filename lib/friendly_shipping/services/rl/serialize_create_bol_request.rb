# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Serializes an R+L API request to create a Bill of Lading (BOL).
      class SerializeCreateBOLRequest
        class << self
          # @param shipment [Physical::Shipment] the shipment for the request
          # @param options [BOLOptions] options for the request
          # @return [Hash] the serialized request
          def call(shipment:, options:)
            {
              BillOfLading: {
                BOLDate: Time.now.strftime('%m/%d/%Y'),
                Shipper: SerializeLocation.call(shipment.origin),
                Consignee: SerializeLocation.call(shipment.destination),
                BillTo: SerializeLocation.call(shipment.origin),
                Items: serialize_items(shipment, options),
                DeclaredValue: serialize_declared_value(options.declared_value),
                SpecialInstructions: options.special_instructions,
                ReferenceNumbers: serialize_reference_numbers(options.reference_numbers),
                AdditionalServices: options.additional_service_codes
              }.compact,
              PickupRequest: serialize_pickup_request(options),
              GenerateUniversalPro: !!options.generate_universal_pro
            }.compact
          end

          private

          # @param shipment [Physical::Shipment] the shipment with items to serialize
          # @param options [BOLOptions] options for the items to be serialized
          # @return [Hash]
          def serialize_items(shipment, options)
            if options.packages_serializer
              warn "[DEPRECATION] `packages_serializer` is deprecated.  Please use `structures_serializer` instead."
              options.packages_serializer.call(packages: shipment.packages, options: options)
            else
              options.structures_serializer.call(structures: shipment.structures, options: options)
            end
          end

          # @param declared_value [Numeric] the declared value to serialize
          # @return [Hash, nil] the serialized declared value or nil if the value is blank
          def serialize_declared_value(declared_value)
            return if declared_value.blank?

            {
              Amount: declared_value,
              Per: "1"
            }
          end

          # @param reference_numbers [Hash] the reference numbers to serialize
          # @return [Hash, nil] the serialized reference numbers or nil if the reference numbers are blank
          def serialize_reference_numbers(reference_numbers)
            return if reference_numbers.blank?

            {
              ShipperNumber: reference_numbers[:shipper_number],
              RateQuoteNumber: reference_numbers[:rate_quote_number],
              PONumber: reference_numbers[:po_number]
            }.compact
          end

          # @param options [BOLOptions] the options containing pickup information
          # @return [Hash, nil] the serialized pickup request
          def serialize_pickup_request(options)
            pickup_time_window = options.pickup_time_window
            return if pickup_time_window.nil?

            {
              PickupInformation: {
                PickupDate: pickup_time_window.begin.strftime('%m/%d/%Y'),
                ReadyTime: pickup_time_window.begin.strftime('%I:%M %p'),
                CloseTime: pickup_time_window.end.strftime('%I:%M %p'),
                AdditionalInstructions: options.pickup_instructions
              }.compact
            }
          end
        end
      end
    end
  end
end
