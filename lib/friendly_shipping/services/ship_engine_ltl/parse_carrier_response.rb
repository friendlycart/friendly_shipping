# frozen_string_literal: true

require 'json'

module FriendlyShipping
  module Services
    class ShipEngineLTL
      # Parses the carriers API response.
      class ParseCarrierResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request to attach to the API result
          # @param response [Response] the response to parse
          # @return [Success<ApiResult<Array<Carrier>>>, Failure<ApiResult<Array<String>>>] the parsed carriers or errors
          def call(request:, response:)
            parsed_json = JSON.parse(response.body)
            carriers = parsed_json.fetch('carriers', []).map do |carrier_data|
              FriendlyShipping::Carrier.new(
                id: carrier_data['carrier_id'],
                name: carrier_data['name'],
                data: {
                  countries: carrier_data['countries'],
                  features: carrier_data['features'],
                  scac: carrier_data['scac']
                }
              )
            end

            if carriers.any?
              Success(
                ApiResult.new(
                  carriers,
                  original_request: request,
                  original_response: response
                )
              )
            else
              errors = parsed_json.fetch('errors', [{ 'message' => 'Unknown error' }])
              Failure(
                ApiResult.new(
                  errors.map { |e| e['message'] },
                  original_request: request,
                  original_response: response
                )
              )
            end
          end
        end
      end
    end
  end
end
