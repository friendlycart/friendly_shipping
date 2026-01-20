# frozen_string_literal: true

module FriendlyShipping
  module Services
    class G2Mint
      module REST
        # Parses a rates response into an `ApiResult`.
        class ParseRatesResponse
          class << self
            # @param request [Request] the original request
            # @param response [RestClient::Response] the response to parse
            # @return [ApiResult<Array<Rate>>] the parsed result
            def call(request:, response:)
              json = JSON.parse(response.body)

              # G2Mint returns an array of carrier results
              rates = json.flat_map do |carrier_result|
                parse_carrier_rates(carrier_result)
              end

              FriendlyShipping::ApiResult.new(
                rates,
                original_request: request,
                original_response: response
              )
            end

            private

            # @param carrier_result [Hash] a single carrier's rate result
            # @return [Array<Rate>]
            def parse_carrier_rates(carrier_result)
              carrier_code = carrier_result['scac']
              carrier_name = carrier_result.dig('rateList', 0, 'carrierName')
              request_id = carrier_result['requestId']

              Array.wrap(carrier_result['rateList']).map do |rate_data|
                parse_rate(rate_data, carrier_code, carrier_name, request_id)
              end
            end

            # @param rate_data [Hash] a single rate
            # @param carrier_code [String] the carrier SCAC code
            # @param carrier_name [String] the carrier name
            # @param request_id [String] the request ID
            # @return [Rate]
            def parse_rate(rate_data, carrier_code, carrier_name, request_id)
              service_level = rate_data['serviceLevel']

              # Find or create a shipping method for this service level
              shipping_method = find_shipping_method(service_level) || create_shipping_method(service_level)

              # Parse pricing information
              pricing = rate_data['pricing'] || {}
              total_price = pricing['totalPrice'] || 0
              currency = rate_data['currency'] || 'USD'

              total = Money.new((total_price.to_f * 100).round, currency)

              # Build additional data
              data = {
                request_id: request_id,
                carrier_code: carrier_code,
                carrier_name: carrier_name || rate_data['carrierName'],
                service_level: service_level,
                quote_number: rate_data['quoteNumber'],
                delivery_date: rate_data['deliveryDate'],
                estimated_transit_time: rate_data['estimatedTransitTime'],
                pricing: {
                  subtotal: pricing['subtotal'],
                  discount_percentage: pricing['discountPercentage'],
                  discount_amount: pricing['discountAmount'],
                  line_haul: pricing['lineHaul'],
                  fuel_surcharge: pricing['fuelSurcharge'],
                  accessorial_total: pricing['accessorialTotal'],
                  linehaul_gross: pricing['linehaulGross']
                }.compact,
                accessorials: rate_data['accessorials'] || [],
                disclaimers: rate_data['disclaimers'] || []
              }.compact

              FriendlyShipping::Rate.new(
                amounts: { total: total },
                shipping_method: shipping_method,
                data: data
              )
            end

            # @param service_level [String] the service level name
            # @return [ShippingMethod, nil]
            def find_shipping_method(service_level)
              SHIPPING_METHODS.detect do |sm|
                sm.name.downcase.include?(service_level.to_s.downcase) ||
                  service_level.to_s.downcase.include?(sm.name.downcase)
              end
            end

            # @param service_level [String] the service level name
            # @return [ShippingMethod]
            def create_shipping_method(service_level)
              FriendlyShipping::ShippingMethod.new(
                name: service_level || "LTL Freight",
                service_code: service_level&.downcase&.gsub(/\s+/, '_') || 'standard',
                origin_countries: ORIGIN_COUNTRIES
              )
            end
          end
        end
      end
    end
  end
end
