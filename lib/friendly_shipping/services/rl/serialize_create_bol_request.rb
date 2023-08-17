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
                Shipper: serialize_location(shipment.origin),
                Consignee: serialize_location(shipment.destination),
                BillTo: serialize_location(shipment.origin),
                Items: options.packages_serializer.call(packages: shipment.packages, options: options),
                DeclaredValue: serialize_declared_value(options.declared_value),
                ReferenceNumbers: serialize_reference_numbers(options.reference_numbers),
                AdditionalServices: options.additional_service_codes
              }.compact,
              PickupRequest: serialize_pickup_request(options.pickup_time_window),
              GenerateUniversalPro: !!options.generate_universal_pro
            }.compact
          end

          private

          # @param [Physical::Location] location
          # @return [Hash]
          def serialize_location(location)
            {
              CompanyName: location.company_name.presence || location.name,
              AddressLine1: location.address1,
              AddressLine2: location.address2,
              City: location.city,
              StateOrProvince: location.region.code,
              ZipOrPostalCode: location.zip,
              CountryCode: location.country.alpha_3_code,
              PhoneNumber: clean_phone(location.phone),
              EmailAddress: location.email
            }.compact
          end

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

          # @param [Range] pickup_time_window
          # @return [Hash, nil]
          def serialize_pickup_request(pickup_time_window)
            return if pickup_time_window.nil?

            {
              PickupInformation: {
                PickupDate: pickup_time_window.begin.strftime('%m/%d/%Y'),
                ReadyTime: pickup_time_window.begin.strftime('%I:%M %p'),
                CloseTime: pickup_time_window.end.strftime('%I:%M %p')
              }
            }
          end

          # RL does not support leading country codes in phone numbers.
          #
          # @param [String] phone
          # @return [String]
          def clean_phone(phone)
            phone.gsub(/^1-/, "")
          end
        end
      end
    end
  end
end
