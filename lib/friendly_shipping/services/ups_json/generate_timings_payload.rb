# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class GenerateTimingsPayload
        def self.call(shipment:, options:)
          {
            originCountryCode: shipment.origin.country.code,
            originStateProvince: region_name_or_code(shipment.origin, shipment.origin.region),
            originCityName: shipment.origin.city,
            originPostalCode: shipment.origin.zip,
            destinationCountryCode: shipment.destination.country.code,
            destinationStateProvince: region_name_or_code(shipment.destination, shipment.destination.region),
            destinationCityName: shipment.destination.city,
            destinationPostalCode: shipment.destination.zip,
            residentialIndicator: shipment.destination.commercial? ? '02' : '01',
            shipDate: options.pickup.strftime('%Y-%m-%d'),
            shipmentContentsCurrencyCode: 'USD',
            shipmentContentsValue: shipment_contents_value(shipment),
            weight: shipment.packages.sum(&:weight).value.to_s,
            weightUnitOfMeasure: 'LBS',
            billType: '02',
            numberOfPackages: shipment.packages.size.to_s
          }
        end

        def self.shipment_contents_value(shipment)
          shipment.packages.map do |package|
            package.items.sum { |item| item.cost || 0 }
          end.sum.to_d
        end

        def self.region_name_or_code(location, region)
          if location.country == "US"
            region.name
          else
            region.code
          end
        end
      end
    end
  end
end
