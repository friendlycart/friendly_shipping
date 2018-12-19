module FriendlyShipping
  module Services
    class ShipEngine
      class ParseCarrierResponse
        def initialize(response:)
          @response = response
        end

        def call
          parsed_json = JSON.parse(@response.body)
          parsed_json['carriers'].map do |carrier_json|
            FriendlyShipping::Carrier.new(
              id: carrier_json['carrier_id'],
              name: carrier_json['friendly_name'],
              code: carrier_json['carrier_code'],
              shipping_methods: carrier_json['services'],
              balance: carrier_json['balance'],
              data: carrier_json
            )
          end
        end
      end
    end
  end
end
