require 'json'

module FriendlyShipping
  module Services
    class ShipEngine
      class ParseLabelResponse
        def initialize(response:)
          @response = response
        end

        def call
          parsed_json = JSON.parse(@response.body)
          [
            FriendlyShipping::Label.new(
              id: parsed_json['label_id'],
              shipment_id: parsed_json['shipment_id'],
              tracking_number: parsed_json['tracking_number'],
              service_code: parsed_json['service_code'],
              label_href: parsed_json['label_download']['href'],
              data: parsed_json
            )
          ]
        end
      end
    end
  end
end
