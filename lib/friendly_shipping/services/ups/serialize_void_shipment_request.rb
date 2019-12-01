# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializeVoidShipmentRequest
        def self.call(label:)
          xml_builder = Nokogiri::XML::Builder.new do |xml|
            xml.VoidShipmentRequest do
              xml.Request do
                xml.RequestAction('Void')
              end
              xml.ShipmentIdentificationNumber(label.tracking_number)
            end
          end
          xml_builder.to_xml
        end
      end
    end
  end
end
