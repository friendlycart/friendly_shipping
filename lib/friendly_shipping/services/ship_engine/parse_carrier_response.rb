module FriendlyShipping
  module Services
    class ShipEngine
      class ParseCarrierResponse
        def initialize(response:)
          @response = response
        end

        def call
          parsed_json = JSON.parse(@response.body)
          parsed_json['carriers'].map do |carrier_data|
            FriendlyShipping::Carrier.new(
              id: carrier_data['carrier_id'],
              name: carrier_data['friendly_name'],
              code: carrier_data['carrier_code'],
              shipping_methods: parse_shipping_methods(carrier_data['services']),
              balance: carrier_data['balance'],
              data: carrier_data
            )
          end
        end

        private

        def parse_shipping_methods(shipping_methods_data)
          shipping_methods_data.map do |shipping_method_data|
            FriendlyShipping::ShippingMethod.new(
              name: shipping_method_data["name"],
              service_code: shipping_method_data["service_code"],
              domestic: shipping_method_data["domestic"],
              international: shipping_method_data["international"],
              multi_package: shipping_method_data["is_multi_package_supported"]
            )
          end
        end
      end
    end
  end
end
