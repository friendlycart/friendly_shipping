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
                DeclaredValue: serialize_declared_value(options),
                AdditionalServices: options.additional_service_codes
              }.compact,
              PickupRequest: serialize_pickup_request(options),
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
              PhoneNumber: location.phone,
              EmailAddress: location.email
            }.compact
          end

          # @param [FriendlyShipping::Services::RL::QuoteOptions] options
          # @return [Hash, nil]
          def serialize_declared_value(options)
            return if options.declared_value.blank?

            {
              Amount: options.declared_value,
              Per: "1"
            }
          end

          # @param [FriendlyShipping::Services::RL::QuoteOptions] options
          # @return [Hash, nil]
          def serialize_pickup_request(options)
            return if options.pickup_time_window.nil?

            {
              PickupInformation: {
                PickupDate: options.pickup_time_window.begin.strftime('%m/%d/%Y'),
                ReadyTime: options.pickup_time_window.begin.strftime('%I:%M %p'),
                CloseTime: options.pickup_time_window.end.strftime('%I:%M %p')
              }
            }
          end
        end
      end
    end
  end
end
