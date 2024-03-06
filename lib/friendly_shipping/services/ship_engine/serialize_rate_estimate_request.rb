# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      class SerializeRateEstimateRequest
        class << self
          def call(shipment:, options:)
            {
              carrier_ids: options.carrier_ids,
              from_country_code: shipment.origin.country.alpha_2_code,
              from_postal_code: shipment.origin.zip,
              to_country_code: shipment.destination.country.alpha_2_code,
              to_postal_code: shipment.destination.zip,
              to_city_locality: shipment.destination.city,
              to_state_province: shipment.destination.region.code,
              weight: {
                value: shipment.packages.map { |p| p.weight.convert_to(:pound).value.to_f }.sum.round(2),
                unit: 'pound'
              },
              dimensions: dimensions(shipment.packages),
              confirmation: 'none',
              ship_date: options.ship_date.strftime('%Y-%m-%d'),
            }.merge(SerializeAddressResidentialIndicator.call(shipment.destination)).compact_blank
          end

          private

          def dimensions(packages)
            length = packages.map { |p| p.length.convert_to(:inch).value.to_f }.sum.round(2)
            width = packages.map { |p| p.width.convert_to(:inch).value.to_f }.sum.round(2)
            height = packages.map { |p| p.height.convert_to(:inch).value.to_f }.sum.round(2)
            return {} if length == 0 && width == 0 && height == 0

            {
              unit: 'inch',
              length: length,
              width: width,
              height: height
            }
          end
        end
      end
    end
  end
end
