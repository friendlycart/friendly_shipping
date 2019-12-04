# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializeTimeInTransitRequest
        def self.call(shipment:, options:)
          xml_builder = Nokogiri::XML::Builder.new do |xml|
            xml.TimeInTransitRequest do
              xml.Request do
                if options.customer_context
                  xml.TransactionReference do
                    xml.CustomerContext(options.customer_context)
                  end
                end
                xml.RequestAction('TimeInTransit')
              end
              xml.TransitFrom do
                xml.AddressArtifactFormat do
                  xml.PoliticalDivision2(shipment.origin.city)
                  xml.PoliticalDivision1(shipment.origin.region.code)
                  xml.CountryCode(shipment.origin.country.code)
                  xml.PostcodePrimaryLow(shipment.origin.zip)
                end
              end
              xml.TransitTo do
                xml.AddressArtifactFormat do
                  # We no longer include the destination city since it doesn't seem to change the timing
                  # result and can prevent the time in transit request from succeeding when invalid.
                  xml.CountryCode(shipment.destination.country.code)
                  xml.PostcodePrimaryLow(shipment.destination.zip)
                end
              end
              xml.ShipmentWeight do
                xml.UnitOfMeasurement do
                  xml.Code('LBS')
                end
                shipment_weight = shipment.packages.map(&:weight).inject(Measured::Weight(0, :pounds), :+)
                xml.Weight(shipment_weight.convert_to(:pounds).value.to_f.round(3))
              end
              xml.InvoiceLineTotal do
                xml.CurrencyCode(options.invoice_total.currency.iso_code)
                xml.MonetaryValue(options.invoice_total.to_f.round(2))
              end
              xml.PickupDate(options.pickup.strftime('%Y%m%d'))
            end
          end
          xml_builder.to_xml
        end
      end
    end
  end
end
