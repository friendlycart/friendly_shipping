# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class ParseTimingsResponse
        class << self
          def call(request:, response:, shipment:)
            parsed_response = ParseJsonResponse.call(
              request: request,
              response: response,
              expected_root_key: 'emsResponse'
            )
            parsed_response.fmap do |parsing_result|
              FriendlyShipping::ApiResult.new(
                build_timings(parsing_result, shipment),
                original_request: request,
                original_response: response
              )
            end
          end

          def build_timings(timings_result, shipment)
            service_timings = Array.wrap(timings_result.dig('emsResponse', 'services'))
            service_timings.map do |timing|
              service_description = timing['serviceLevelDescription']
              shipping_method = SHIPPING_METHODS.detect do |potential_shipping_method|
                service_description == potential_shipping_method.name &&
                  potential_shipping_method.origin_countries.map(&:code).include?(shipment.origin.country.code)
              end
              delivery_date = timing['deliveryDate']
              delivery_time = timing['deliveryTime']
              delivery = Time.parse("#{delivery_date} #{delivery_time}")
              pickup_date = timing['pickupDate']
              pickup_time = timing['pickupTime']
              pickup = Time.parse("#{pickup_date} #{pickup_time}")

              guaranteed = timing['guaranteeIndicator'] == '1'
              business_transit_days = timing['businessTransitDays']

              FriendlyShipping::Timing.new(
                shipping_method: shipping_method,
                pickup: pickup,
                delivery: delivery,
                guaranteed: guaranteed,
                data: {
                  business_transit_days: business_transit_days
                }
              )
            end
          end
        end
      end
    end
  end
end
