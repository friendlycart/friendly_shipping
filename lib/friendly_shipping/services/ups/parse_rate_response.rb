# frozen_string_literal: true

require 'friendly_shipping/services/ups/parse_xml_response'

module FriendlyShipping
  module Services
    class Ups
      class ParseRateResponse
        def self.call(request:, response:, shipment:)
          parsing_result = ParseXMLResponse.(response.body, 'RatingServiceSelectionResponse')
          parsing_result.fmap do |xml|
            rate_estimates = xml.root.css('> RatedShipment').map do |rated_shipment|
              service_code = rated_shipment.at('Service/Code').text
              shipping_method = CARRIER.shipping_methods.detect do |shipping_method|
                shipping_method.service_code == service_code && shipment.origin.country.in?(shipping_method.origin_countries)
              end
              days_to_delivery = rated_shipment.at('GuaranteedDaysToDelivery').text.to_i
              currency = Money::Currency.new(rated_shipment.at('TotalCharges/CurrencyCode').text)
              total_cents = rated_shipment.at('TotalCharges/MonetaryValue').text.to_d * currency.subunit_to_unit
              insurance_price = rated_shipment.at('ServiceOptionsCharges/MonetaryValue').text.to_f
              negotiated_rate = rated_shipment.at('NegotiatedRates/NetSummaryCharges/GrandTotal/MonetaryValue')&.text.to_f

              FriendlyShipping::Rate.new(
                shipping_method: shipping_method,
                amounts: { total: Money.new(total_cents, currency) },
                warnings: [rated_shipment.at("RatedShipmentWarning")&.text].compact,
                errors: [],
                data: {
                  insurance_price: insurance_price,
                  negotiated_rate: negotiated_rate,
                  days_to_delivery: days_to_delivery
                },
                original_request: request,
                original_response: response
              )
            end
          end
        end
      end
    end
  end
end
