# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializeShipmentAcceptRequest
        def self.call(digest:, options:)
          xml_builder = Nokogiri::XML::Builder.new do |xml|
            xml.ShipmentAcceptRequest do
              xml.Request do
                xml.RequestAction('ShipAccept')
                xml.SubVersion('1707')
                if options.customer_context
                  xml.TransactionReference do
                    xml.CustomerContext(options.customer_context)
                  end
                end
              end
              xml.ShipmentDigest(digest)
            end
          end
          xml_builder.to_xml
        end
      end
    end
  end
end
