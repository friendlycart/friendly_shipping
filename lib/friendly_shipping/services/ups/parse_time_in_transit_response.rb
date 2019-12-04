# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class ParseTimeInTransitResponse
        def self.call(request:, response:)
          parsing_result = ParseXMLResponse.call(response.body, 'TimeInTransitResponse')
          parsing_result.fmap do |xml|
            origin_country_code = xml.at('TransitResponse/TransitFrom/AddressArtifactFormat/CountryCode').text
            timings = xml.root.xpath('//TransitResponse/ServiceSummary').map do |service_summary|
              # First find the shipping method
              service_description = service_summary.at('Service/Description').text.gsub(/\s+/, ' ').strip
              shipping_method = SHIPPING_METHODS.detect do |potential_shipping_method|
                potential_shipping_method.name.starts_with?(service_description) &&
                  potential_shipping_method.origin_countries.map(&:code).include?(origin_country_code)
              end

              # Figure out the dates and times
              delivery_date = service_summary.at('EstimatedArrival/Date').text
              delivery_time = service_summary.at('EstimatedArrival/Time').text
              delivery = Time.parse("#{delivery_date} #{delivery_time}")
              pickup_date = service_summary.at('EstimatedArrival/PickupDate').text
              pickup_time = service_summary.at('EstimatedArrival/PickupTime').text
              pickup = Time.parse("#{pickup_date} #{pickup_time}")

              # Some additional data
              guaranteed = service_summary.at('Guaranteed/Code').text == 'Y'
              business_transit_days = service_summary.at('EstimatedArrival/BusinessTransitDays').text

              FriendlyShipping::Timing.new(
                shipping_method: shipping_method,
                pickup: pickup,
                delivery: delivery,
                guaranteed: guaranteed,
                properties: {
                  business_transit_days: business_transit_days
                }
              )
            end

            FriendlyShipping::ApiResult.new(
              timings,
              original_request: request,
              original_response: response
            )
          end
        end
      end
    end
  end
end
