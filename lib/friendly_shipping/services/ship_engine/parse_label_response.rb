# frozen_string_literal: true

require 'json'

module FriendlyShipping
  module Services
    class ShipEngine
      # Parses the labels API response.
      class ParseLabelResponse
        # @param request [Request] the request to attach to the API result
        # @param response [Response] the response to parse
        # @return [ApiResult<Array<Label>] the parsed labels (ShipEngine only returns one label at a time)
        def self.call(request:, response:)
          parsed_json = JSON.parse(response.body)

          label_uri_string = parsed_json['label_download']['href']
          label_data = nil
          label_url = nil
          if label_uri_string.starts_with?('data')
            # This URI has the following form:
            # data:application/zpl;base64,XlhBDQpeTEwxMjE4....
            # We don't know the content type here, but we can assume Base64
            # encoding.
            # This next line splits the URI at the first occurrence of ";base64,",
            # giving us the desired base64 encoded string.
            _, base64_encoded = label_uri_string.split(";base64,", 2)
            label_data = Base64.decode64(base64_encoded)
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
