# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class ParseCityStateLookupResponse
        extend Dry::Monads::Result::Mixin

        def self.call(request:, response:)
          parsed_response = ParseJsonResponse.call(
            request: request,
            response: response,
            expected_root_key: 'XAVResponse'
          )
          parsed_response.bind do |city_state_lookup_response|
            if city_state_lookup_response['XAVResponse'].keys.include?('NoCandidatesIndicator')
              Failure(
                FriendlyShipping::ApiResult.new(
                  "No candidates found.",
                  original_request: request,
                  original_response: response
                )
              )
            else
              candidate = city_state_lookup_response.dig('XAVResponse', 'Candidate').first
              Success(
                FriendlyShipping::ApiResult.new(
                  Physical::Location.new(
                    city: candidate.dig('AddressKeyFormat', 'PoliticalDivision2'),
                    region: candidate.dig('AddressKeyFormat', 'PoliticalDivision1'),
                    country: candidate.dig('AddressKeyFormat', 'CountryCode'),
                    zip: candidate.dig('AddressKeyFormat', 'PostcodePrimaryLow')
                  ),
                  original_request: request,
                  original_response: response
                )
              )
            end
          end
        end
      end
    end
  end
end
