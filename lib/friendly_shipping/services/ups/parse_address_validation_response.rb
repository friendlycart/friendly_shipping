# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class ParseAddressValidationResponse
        extend Dry::Monads::Result::Mixin

        def self.call(_request:, response:, _location:)
          parsing_result = ParseXMLResponse.call(response.body, 'AddressValidationResponse')

          parsing_result.bind do |xml|
            if xml.at('NoCandidatesIndicator')
              Failure('Address is probably invalid. No similar valid addresses found.')
            else
              Success(
                Physical::Location.new(
                  address1: xml.xpath('//AddressKeyFormat/AddressLine')[0]&.text,
                  address2: xml.xpath('//AddressKeyFormat/AddressLine')[1]&.text,
                  city: xml.at('AddressKeyFormat/PoliticalDivision2')&.text,
                  region: xml.at('AddressKeyFormat/PoliticalDivision1')&.text,
                  country: xml.at('AddressKeyFormat/CountryCode')&.text,
                  zip: xml.at('AddressKeyFormat/PostcodePrimaryLow')&.text,
                  address_type: xml.at('AddressClassification/Description')&.text&.downcase
                )
              )
            end
          end
        end
      end
    end
  end
end
