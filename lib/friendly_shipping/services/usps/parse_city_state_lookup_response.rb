# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      class ParseCityStateLookupResponse
        class << self
          # Parse a response from USPS' city/state lookup API
          #
          # @param [FriendlyShipping::Request] request The request that was used to obtain this Response
          # @param [FriendlyShipping::Response] response The response that USPS returned
          # @param [Physical::Location] location The location object we're trying to get results for
          # @return [Result<FriendlyShipping::AddressValidationResult>]
          def call(request:, response:, location:)
            # Filter out error responses and directly return a failure
            parsing_result = ParseXMLResponse.call(response.body, 'CityStateLookupResponse')
            parsing_result.fmap do |xml|
              address = xml.root.at('ZipCode')
              result_location = Physical::Location.new(
                city: address&.at('City')&.text,
                region: address&.at('State')&.text,
                zip: address&.at('Zip5')&.text,
                country: 'US'
              )

              FriendlyShipping::ZipCodeLookupResult.new(
                location: result_location,
                original_request: request,
                original_response: response,
                original_location: location
              )
            end
          end
        end
      end
    end
  end
end
