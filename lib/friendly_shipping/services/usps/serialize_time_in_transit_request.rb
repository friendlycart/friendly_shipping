# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      class SerializeTimeInTransitRequest
        def self.call(shipment:, options:, login:)
          xml_builder = Nokogiri::XML::Builder.new do |xml|
            xml.SDCGetLocationsRequest(USERID: login) do
              xml.MailClass 0 # all mail classes
              xml.OriginZIP shipment.origin.zip
              xml.DestinationZIP shipment.destination.zip
              xml.AcceptDate options.pickup.strftime('%d-%b-%Y')
              xml.NonEMDetail true
            end
          end
          xml_builder.to_xml
        end
      end
    end
  end
end
