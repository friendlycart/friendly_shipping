# frozen_string_literal: true

require 'json'
require 'data_uri'

module FriendlyShipping
  module Services
    class ShipEngine
      class ParseLabelResponse
        def self.call(request:, response:)
          parsed_json = JSON.parse(response.body)

          label_uri_string = parsed_json['label_download']['href']
          label_data = nil
          label_url = nil
          if label_uri_string.starts_with?('data')
            label_data = URI::Data.new(label_uri_string).data
          else
            label_url = label_uri_string
          end

          currency = parsed_json.dig('shipment_cost', 'currency')
          cents = parsed_json.dig('shipment_cost', 'amount') * 100
          shipment_cost = Money.new(cents, currency)

          label = FriendlyShipping::Label.new(
            id: parsed_json['label_id'],
            shipment_id: parsed_json['shipment_id'],
            tracking_number: parsed_json['tracking_number'],
            service_code: parsed_json['service_code'],
            label_href: label_url,
            label_data: label_data,
            label_format: parsed_json['label_format'].to_sym,
            shipment_cost: shipment_cost,
            cost: shipment_cost,
            data: parsed_json
          )

          ApiResult.new([label], original_request: request, original_response: response)
        end
      end
    end
  end
end
