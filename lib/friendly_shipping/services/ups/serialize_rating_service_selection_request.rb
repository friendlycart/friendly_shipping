# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializeRatingServiceSelectionRequest
        def self.call(shipment:, options:)
          shipper = options.shipper || shipment.origin

          xml_builder = Nokogiri::XML::Builder.new do |xml|
            xml.RatingServiceSelectionRequest do
              xml.Request do
                xml.RequestAction('Rate')
                # If no shipping method is given, request all of them
                # I one is given, omit the request option. It then becomes "Rate", the default.
                xml.RequestOption('Shop') unless options.shipping_method
                xml.SubVersion(options.sub_version)
                # Optional element to identify transactions between client and server.
                if options.customer_context
                  xml.TransactionReference do
                    xml.CustomerContext(options.customer_context)
                  end
                end
              end

              xml.PickupType do
                xml.Code(options.pickup_type_code)
              end
              xml.CustomerClassification do
                xml.Code(options.customer_classification_code)
              end

              xml.Shipment do
                # not implemented: Shipment/Description element
                xml.Shipper do
                  SerializeAddressSnippet.call(xml: xml, location: shipper)

                  xml.ShipperNumber(options.shipper_number)
                end

                xml.ShipTo do
                  SerializeAddressSnippet.call(xml: xml, location: shipment.destination)

                  if options.destination_account
                    xml.ShipperAssignedIdentificationNumber(options.destination_account)
                  end
                end

                if shipper != shipment.origin
                  xml.ShipFrom do
                    SerializeAddressSnippet.call(xml: xml, location: shipment.origin)
                  end
                end

                if options.pickup_date && options.sub_version.to_i >= 2205
                  xml.DeliveryTimeInformation do
                    xml.Pickup do
                      xml.Date options.pickup_date.strftime('%Y%m%d')
                      xml.Time options.pickup_date.strftime('%H%M')
                    end
                  end
                end

                shipment.packages.each do |package|
                  package_options = options.options_for_package(package)
                  SerializePackageNode.call(
                    xml: xml,
                    package: package,
                    transmit_dimensions: package_options.transmit_dimensions
                  )
                end

                if options.shipping_method
                  xml.Service do
                    xml.Code options.shipping_method.service_code
                  end
                end

                xml.ShipmentServiceOptions do
                  xml.UPScarbonneutralIndicator if options.carbon_neutral
                  xml.SaturdayDelivery if options.saturday_delivery
                  xml.SaturdayPickup if options.saturday_pickup
                end

                if options.negotiated_rates
                  xml.RateInformation do
                    xml.NegotiatedRatesIndicator if options.negotiated_rates
                  end
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
