# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializeAddressValidationRequest
        attr_reader :location

        REQUEST_ACTION = 'XAV'
        REQUEST_OPTIONS = {
          validation: 1,
          classification: 2,
          both: 3
        }.freeze

        def self.call(location:)
          xml_builder = Nokogiri::XML::Builder.new do |xml|
            xml.AddressValidationRequest do
              xml.Request do
                xml.RequestAction REQUEST_ACTION
                xml.RequestOption REQUEST_OPTIONS[:both]
              end

              xml.AddressKeyFormat do
                xml.AddressLine location.address1
                xml.AddressLine location.address2
                xml.PoliticalDivision2 location.city
                xml.PoliticalDivision1 location.region.code
                xml.PostcodePrimaryLow location.zip
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
