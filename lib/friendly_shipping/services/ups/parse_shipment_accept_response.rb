# frozen_string_literal: true

require 'dry/monads'
require 'friendly_shipping/services/ups/parse_money_element'

module FriendlyShipping
  module Services
    class Ups
      class ParseShipmentAcceptResponse
        extend Dry::Monads::Result::Mixin

        class << self
          def call(request:, response:)
            parsing_result = ParseXMLResponse.call(
              request: request,
              response: response,
              expected_root_tag: 'ShipmentAcceptResponse'
            )
            parsing_result.fmap do |xml|
              FriendlyShipping::ApiResult.new(
                build_labels(xml),
                original_request: request,
                original_response: response
              )
            end
          end

          private

          def build_labels(xml)
            packages = xml.xpath('//ShipmentAcceptResponse/ShipmentResults/PackageResults')
            form_format = xml.at('Form/Image/ImageFormat/Code')&.text
            encoded_form = xml.at('Form/Image/GraphicImage')&.text
            decoded_form = encoded_form ? Base64.decode64(encoded_form) : nil
            packages.map do |package|
              cost_breakdown = build_cost_breakdown(package)
              package_cost = cost_breakdown.values.any? ? cost_breakdown.values.sum : nil
              encoded_label_data = package.at('LabelImage/GraphicImage')&.text
              FriendlyShipping::Label.new(
                tracking_number: package.at('TrackingNumber').text,
                label_data: encoded_label_data ? Base64.decode64(encoded_label_data) : nil,
                label_format: package.at('LabelImage/LabelImageFormat/Code')&.text,
                cost: package_cost,
                shipment_cost: get_shipment_cost(xml),
                data: {
                  cost_breakdown: cost_breakdown,
                  negotiated_rate: get_negotiated_rate(xml),
                  form_format: form_format,
                  form: decoded_form,
                  customer_context: xml.xpath('//TransactionReference/CustomerContext')&.text
                }.compact
              )
            end
          end

          def build_cost_breakdown(package)
            cost_elements = [
              package.at('BaseServiceCharge'),
              package.at('ServiceOptionsCharges'),
              package.xpath('ItemizedCharges')
            ].flatten

            cost_elements.map { |element| ParseMoneyElement.call(element) }.compact.to_h
          end

          def get_shipment_cost(shipment_xml)
            total_charges_element = shipment_xml.at('ShipmentResults/ShipmentCharges/TotalCharges')
            ParseMoneyElement.call(total_charges_element).last
          end

          def get_negotiated_rate(shipment_xml)
            negotiated_total_element = shipment_xml.at('NegotiatedRates/NetSummaryCharges/GrandTotal')
            ParseMoneyElement.call(negotiated_total_element)&.last
          end
        end
      end
    end
  end
end
