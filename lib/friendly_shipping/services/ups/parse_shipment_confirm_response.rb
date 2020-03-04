# frozen_string_literal: true

require 'dry/monads/result'

module FriendlyShipping
  module Services
    class Ups
      class ParseShipmentConfirmResponse
        def self.call(request:, response:)
          parsing_result = ParseXMLResponse.call(
            request: request,
            response: response,
            expected_root_tag: 'ShipmentConfirmResponse'
          )
          parsing_result.fmap do |xml|
            FriendlyShipping::ApiResult.new(
              xml.root.at('ShipmentDigest').text,
              original_request: request,
              original_response: response
            )
          end
        end
      end
    end
  end
end
