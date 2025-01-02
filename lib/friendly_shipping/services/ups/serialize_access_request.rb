# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializeAccessRequest
        def self.call(login:, password:, key:)
          xml_builder = Nokogiri::XML::Builder.new do |xml|
            xml.AccessRequest do
              xml.AccessLicenseNumber(key)
              xml.UserId(login)
              xml.Password(password)
            end
          end
          xml_builder.to_xml
        end
      end
    end
  end
end
