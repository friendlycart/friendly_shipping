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
          # @param options [RateEstimateOptions]
          # @return [Hash]
          def call(shipment:, options:)
            length, width, height = dimensions(shipment)
            {
              originZIPCode: shipment.origin.zip,
              destinationZIPCode: shipment.destination.zip,
              weight: shipment.packages.sum(&:weight).convert_to(:lbs).value.to_f.round(2),
              length: length.convert_to(:in).value.to_f.round(2),
              width: width.convert_to(:in).value.to_f.round(2),
              height: height.convert_to(:in).value.to_f.round(2),
              mailClass: options.shipping_method.service_code,
              processingCategory: options.processing_category,
              rateIndicator: options.rate_indicator,
              destinationEntryFacilityType: options.destination_entry_facility_type,
              priceType: options.price_type,
              mailingDate: options.mailing_date.strftime("%Y-%m-%d")
            }
          end

          private

          # Sums the length of all packages but uses the max height and width. This is the
          # best approximation we can make of the total dimensions of the shipment.
          #
          # The legacy USPS API supported passing multiple packages, each with their own
          # dimensions, in a single API call. The new API only supports a single package.
          # We may eventually want to start making separate API calls for each package and
          # summing the rates, but for now, this is the best we can do.
          #
          # @param shipment [Physical::Shipment]
          # @return [Array<Measured::Length>]
          def dimensions(shipment)
            length = shipment.packages.sum(&:length)
            width = shipment.packages.map(&:width).max
            height = shipment.packages.map(&:height).max
            [length, width, height].sort.reverse
          end
        end
      end
    end
  end
end
