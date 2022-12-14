# frozen_string_literal: true

require 'dry/monads'

module FriendlyShipping
  module Services
    class Ups
      class ParseVoidShipmentResponse
        def self.call(request:, response:)
          parsing_result = ParseXMLResponse.call(
            request: request,
            response: response,
            expected_root_tag: 'VoidShipmentResponse'
          )
          parsing_result.fmap do |xml|
            FriendlyShipping::ApiResult.new(
              xml.root.at('ResponseStatusDescription').text,
              original_request: request,
              original_response: response
            )
          end
        end
      end
    end
  end
end
