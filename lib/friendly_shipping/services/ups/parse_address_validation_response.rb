# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class ParseAddressValidationResponse
        extend Dry::Monads::Result::Mixin

        def self.call(request:, response:)
          parsing_result = ParseXMLResponse.call(
            request: request,
            response: response,
            expected_root_tag: 'AddressValidationResponse'
          )
          parsing_result.bind do |xml|
            if xml.at('NoCandidatesIndicator')
              Failure(
                FriendlyShipping::ApiFailure.new(
                  'Address is probably invalid. No similar valid addresses found.',
                  original_request: request,
                  original_response: response
                )
              )
            else
              Success(
                FriendlyShipping::ApiResult.new(
                  build_suggestions(xml),
                  original_request: request,
                  original_response: response
                )
              )
            end
          end
        end

        def self.build_suggestions(xml)
          xml.xpath('//AddressKeyFormat').map do |address_fragment|
            Physical::Location.new(
              address1: address_fragment.xpath('AddressLine[1]')[0]&.text,
              address2: address_fragment.xpath('AddressLine[2]')[0]&.text,
              company_name: address_fragment.at('ConsigneeName')&.text,
              city: address_fragment.at('PoliticalDivision2')&.text,
              region: address_fragment.at('PoliticalDivision1')&.text,
              country: address_fragment.at('CountryCode')&.text,
              zip: "#{address_fragment.at('PostcodePrimaryLow')&.text}-#{address_fragment.at('PostcodeExtendedLow')&.text}",
              address_type: address_fragment.at('AddressClassification/Description')&.text&.downcase
            )
          end
        end
      end
    end
  end
end
