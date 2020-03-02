# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      class ParseAddressValidationResponse
        class << self
          # Parse a response from USPS' address validation API
          #
          # @param [FriendlyShipping::Request] request The request that was used to obtain this Response
          # @param [FriendlyShipping::Response] response The response that USPS returned
          # @return [Result<FriendlyShipping::AddressValidationResult>]
          def call(request:, response:)
            # Filter out error responses and directly return a failure
            parsing_result = ParseXMLResponse.call(
              request: request,
              response: response,
              expected_root_tag: 'AddressValidateResponse'
            )
            parsing_result.fmap do |xml|
              address = xml.root.at('Address')
              suggestions = [
                Physical::Location.new(
                  address1: address&.at('Address2')&.text, # USPS swaps Address1 and Address2 in the response
                  address2: address&.at('Address1')&.text,
                  city: address&.at('City')&.text,
                  region: address&.at('State')&.text,
                  zip: address&.at('Zip5')&.text,
                  country: 'US'
                )
              ]
              FriendlyShipping::ApiResult.new(
                suggestions,
                original_request: request,
                original_response: response
              )
            end
          end
        end
      end
    end
  end
end
