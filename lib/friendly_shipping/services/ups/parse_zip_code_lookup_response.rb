# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class ParseZipCodeLookupResponse
        extend Dry::Monads::Result::Mixin

        def self.call(request:, response:, location:)
          parsing_result = ParseXMLResponse.call(response.body, 'AddressValidationResponse')

          parsing_result.fmap do |xml|
            FriendlyShipping::ZipCodeLookupResult.new(
              location: Physical::Location.new(
                city: xml.at('AddressValidationResult/Address/City')&.text,
                region: xml.at('AddressValidationResult/Address/StateProvinceCode')&.text,
                country: location.country,
                zip: xml.at('AddressValidationResult/Address/PostcodePrimaryLow')&.text,
              ),
              original_location: location,
              original_request: request,
              original_response: response
            )
          end
        end
      end
    end
  end
end
