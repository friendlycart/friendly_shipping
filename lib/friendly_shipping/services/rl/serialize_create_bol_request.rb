# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class SerializeCreateBOLRequest
        class << self
          # @param [Physical::Shipment] shipment
          # @param [FriendlyShipping::Services::RL::BillOfLadingOptions] options
          # @return [Hash]
          def call(shipment:, options:)
            {
              BillOfLading: {
                BOLDate: Time.now.strftime('%m/%d/%Y'),
                Shipper: serialize_location(shipment.origin),
                Consignee: serialize_location(shipment.destination),
                BillTo: serialize_location(shipment.origin),
                Items: serialize_items(shipment.packages, options),
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

          # @param [Array<Physical::Package>] packages
          # @param [FriendlyShipping::Services::RL::QuoteOptions] options
          # @return [Array<Hash>]
          def serialize_items(packages, options)
            packages.flat_map do |package|
              package_options = options.options_for_package(package)
              package.items.map do |item|
                item_options = package_options.options_for_item(item)
                {
                  IsHazmat: false,
                  Pieces: 1,
                  PackageType: "BOX",
                  NMFCItemNumber: item_options.nmfc_primary_code,
                  NMFCSubNumber: item_options.nmfc_sub_code,
                  Class: item_options.freight_class,
                  Weight: item.weight.convert_to(:pounds).value.ceil,
                  Description: item.description.presence || "Commodities"
                }.compact
              end
            end
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
