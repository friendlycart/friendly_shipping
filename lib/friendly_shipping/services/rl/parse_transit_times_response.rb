# frozen_string_literal: true

require 'json'
require 'friendly_shipping/services/rl/shipping_methods'

module FriendlyShipping
  module Services
    class RL
      class ParseTransitTimesResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param [FriendlyShipping::Request] request
          # @param [FriendlyShipping::Response] response
          # @return [
          #   Dry::Monads::Success<FriendlyShipping::ApiResult>,
          #   Dry::Monads::Failure<FriendlyShipping::ApiResult>
          # ]
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

          # @param [String] parsed_json
          # @return [Array<FriendlyShipping::Timing>]
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
