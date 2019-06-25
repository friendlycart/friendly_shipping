module FriendlyShipping
  module Services
    class ShipEngine
      class SerializeRateEstimateRequest
        def self.call(shipment:, carriers:)
          {
            carrier_ids: carriers.map(&:id),
            from_country_code: shipment.origin.country.alpha_2_code,
            from_postal_code: shipment.origin.zip,
            to_country_code: shipment.destination.country.alpha_2_code,
            to_postal_code: shipment.destination.zip,
            to_city_locality: shipment.destination.city,
            to_state_province: shipment.destination.region.code,
            weight: {
              value: shipment.packages.map { |p| p.weight.convert_to(:pound).value.to_f }.sum,
              unit: 'pound'
            },
            confirmation: 'none',
            address_residential_indicator: shipment.destination.residential? ? "yes" : "no"
          }
        end
      end
    end
  end
end
