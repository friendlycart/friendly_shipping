# frozen_string_literal: true

require 'nokogiri'
require 'friendly_shipping/services/ups/serialize_address_snippet'
require 'friendly_shipping/services/ups/serialize_package_node'

module FriendlyShipping
  module Services
    class Ups
      class SerializeRatingServiceSelectionRequest
        PICKUP_CODES = HashWithIndifferentAccess.new(
          daily_pickup: "01",
          customer_counter: "03",
          one_time_pickup: "06",
          on_call_air: "07",
          suggested_retail_rates: "11",
          letter_center: "19",
          air_service_center: "20"
        )

        CUSTOMER_CLASSIFICATIONS = HashWithIndifferentAccess.new(
          shipper_number: "00",
          daily_rates: "01",
          retail_rates: "04",
          regional_rates: "05",
          general_rates: "06",
          standard_rates: "53"
        )

        def self.call(shipment:)
          shipper = shipment.options[:shipper] || shipment.origin
          pickup_type = PICKUP_CODES[shipment.options[:pickup_type] || :daily_pickup]
          customer_classification = CUSTOMER_CLASSIFICATIONS[
            shipment.options[:customer_classification] || :daily_rates
          ]
          origin_account = shipment.options[:origin_account]
          destination_account = shipment.options[:destination_account]

          xml_builder = Nokogiri::XML::Builder.new do |xml|
            xml.RatingServiceSelectionRequest do
              xml.Request do
                xml.RequestAction('Rate')
                xml.RequestOption('Shop')
                xml.SubVersion('1707')
              end

              xml.PickupType do
                xml.Code(pickup_type)
              end
              xml.CustomerClassification do
                xml.Code(customer_classification)
              end

              xml.Shipment do
                # not implemented: Shipment/Description element
                xml.Shipper do
                  SerializeAddressSnippet.call(xml: xml, location: shipper)

                  xml.ShipperNumber(origin_account)
                end

                xml.ShipTo do
                  SerializeAddressSnippet.call(xml: xml, location: shipment.destination)

                  if destination_account
                    xml.ShipperAssignedIdentificationNumber(destination_account)
                  end
                end

                if shipper != shipment.origin
                  xml.ShipFrom do
                    SerializeAddressSnippet.call(xml: xml, location: shipment.origin)
                  end
                end

                shipment.packages.each do |package|
                  SerializePackageNode.call(xml: xml, package: package)
                end
              end
            end
          end
          xml_builder.to_xml
        end
      end
    end
  end
end
