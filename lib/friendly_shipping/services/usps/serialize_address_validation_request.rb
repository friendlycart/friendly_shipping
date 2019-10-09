# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      class SerializeAddressValidationRequest
        def self.call(location:, login:)
          xml_builder = Nokogiri::XML::Builder.new do |xml|
            xml.AddressValidateRequest USERID: login do
              xml.Address do
                xml.Address1 location.address2 # USPS swaps Address1 and Address2 in the request
                xml.Address2 location.address1
                xml.City location.city
                xml.State location.region.code
                xml.Zip5 location.zip
                xml.Zip4
              end
            end
          end
          xml_builder.to_xml
        end
      end
    end
  end
end
