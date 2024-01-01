# frozen_string_literal: true

require 'json'
require 'friendly_shipping/services/rl/shipping_methods'

module FriendlyShipping
  module Services
    class RL
      # Parses the response from the R+L API when getting transit times.
      class ParseTransitTimesResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request to attach to the API result
          # @param response [Response] the response to parse
          # @return [Success<ApiResult>, Failure<ApiResult>] the parsed timings
          def call(request:, response:)
            parsed_json = JSON.parse(response.body)
            timings = build_timings(parsed_json)
            if timings.any?
              Success(
                ApiResult.new(
                  timings,
                  original_request: request,
                  original_response: response
                )
              )
            else
              errors = parsed_json.fetch('Errors', [{ 'ErrorMessage' => 'Unknown error' }])
              Failure(
                ApiResult.new(
                  errors.map { |e| e['ErrorMessage'] },
                  original_request: request,
                  original_response: response
                )
              )
            end
          end

          private

          # Builds {Timing} instances from the parsed JSON.
          #
          # @param parsed_json [String] the parsed JSON
          # @return [Array<Timing>] the parsed timings
          def build_timings(parsed_json)
            destinations = parsed_json['Destinations']
            return [] unless destinations

            pickup_date = parsed_json['PickupDate']
            pickup = Time.strptime(pickup_date, '%m/%d/%Y')

            destination = destinations.first

            delivery_date = destination['DeliveryDate']
            delivery = Time.strptime(delivery_date, '%m/%d/%Y')

            days_in_transit = destination['ServiceDays']

            [
              FriendlyShipping::Timing.new(
                shipping_method: SHIPPING_METHODS.first,
                pickup: pickup,
                delivery: delivery,
                guaranteed: false,
                data: {
                  days_in_transit: days_in_transit
                }
              )
            ]
          end
        end
      end
    end
  end
end
