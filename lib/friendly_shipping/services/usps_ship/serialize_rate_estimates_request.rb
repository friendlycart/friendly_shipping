# frozen_string_literal: true

require 'friendly_shipping/services/usps/machinable_package'

module FriendlyShipping
  module Services
    class USPSShip
      class SerializeRateEstimatesRequest
        class << self
          # Serialize a rate estimates request.
          #
          # @param shipment [Physical::Shipment]
          # @param package [Physical::Package]
          # @param options [RateEstimateOptions]
          # @return [Hash]
          def call(shipment:, package:, options:)
            length, width, height = package.dimensions.sort.reverse
            package_options = options.options_for_package(package)
            {
              originZIPCode: shipment.origin.zip,
              destinationZIPCode: shipment.destination.zip,
              weight: package.weight.convert_to(:lbs).value.to_f.round(2),
              length: length.convert_to(:in).value.to_f.round(2),
              width: width.convert_to(:in).value.to_f.round(2),
              height: height.convert_to(:in).value.to_f.round(2),
              mailClass: options.shipping_method.service_code,
              processingCategory: package_options.processing_category,
              rateIndicator: package_options.rate_indicator,
              destinationEntryFacilityType: options.destination_entry_facility_type,
              priceType: package_options.price_type,
              mailingDate: options.mailing_date.strftime("%Y-%m-%d")
            }
          end
        end
      end
    end
  end
end
