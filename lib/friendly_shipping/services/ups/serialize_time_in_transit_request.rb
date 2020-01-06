# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializeTimeInTransitRequest
        MAX_SHIPMENT_WEIGHT = Measured::Weight.new(150, :pounds)

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
                  xml.PoliticalDivision2(shipment.destination.city)
                  xml.PoliticalDivision1(shipment.destination.region.code)
                  xml.CountryCode(shipment.destination.country.code)
                  xml.PostcodePrimaryLow(shipment.destination.zip)
                end
              end
              xml.ShipmentWeight do
                xml.UnitOfMeasurement do
                  xml.Code('LBS')
                end
                shipment_weight = shipment.packages.map(&:weight).inject(Measured::Weight(0, :pounds), :+)
                weight_for_ups = [shipment_weight, MAX_SHIPMENT_WEIGHT].min
                xml.Weight(weight_for_ups.convert_to(:pounds).value.to_f.round(3))
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
