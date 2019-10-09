# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      class SerializeCityStateLookupRequest
        def self.call(location:, login:)
          xml_builder = Nokogiri::XML::Builder.new do |xml|
            xml.CityStateLookupRequest(USERID: login) do
              xml.ZipCode do
                xml.Zip5 location.zip
              end
            end
          end
          xml_builder.to_xml
        end
      end
    end
  end
end
