# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class SerializeCreateBOLRequest
        class << self
          # @param [Physical::Shipment] shipment
          # @param [FriendlyShipping::Services::RL::BOLOptions] options
          # @return [Hash]
          def call(shipment:, options:)
            {
              BillOfLading: {
                BOLDate: Time.now.strftime('%m/%d/%Y'),
                Shipper: SerializeLocation.call(shipment.origin),
                Consignee: SerializeLocation.call(shipment.destination),
                BillTo: SerializeLocation.call(shipment.origin),
                Items: options.packages_serializer.call(packages: shipment.packages, options: options),
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

          # @param [Numeric] declared_value
          # @return [Hash, nil]
          def serialize_declared_value(declared_value)
            return if declared_value.blank?

            {
              Amount: declared_value,
              Per: "1"
            }
          end

          # @param [Hash] reference_numbers
          # @return [Hash, nil]
          def serialize_reference_numbers(reference_numbers)
            return if reference_numbers.blank?

            {
              ShipperNumber: reference_numbers[:shipper_number],
              RateQuoteNumber: reference_numbers[:rate_quote_number],
              PONumber: reference_numbers[:po_number]
            }.compact
          end

          # @param [FriendlyShipping::Services::RL::BOLOptions] options
          # @return [Hash, nil]
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
