# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializeCityStateLookupRequest
        REQUEST_ACTION = 'AV'

        def self.call(location:)
          xml_builder = Nokogiri::XML::Builder.new do |xml|
            xml.AddressValidationRequest do
              xml.Request do
                xml.RequestAction REQUEST_ACTION
              end
              xml.Address do
                xml.PostalCode location.zip
                xml.CountryCode location.country.code
              end
            end
          end
          xml_builder.to_xml
        end
      end
    end
  end
end
