# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Error raised for failed UPS JSON API requests. The message is built from the error messages in the
      # response body, if present.
      class ApiError < FriendlyShipping::ApiError
        # @param cause [RestClient::Exception] the underlying HTTP error
        def initialize(cause)
          super(cause, parse_message(cause))
        end

        private

        # @param error [RestClient::Exception] the underlying HTTP error
        # @return [String, nil] the error message(s) from the response, or nil if the body cannot be parsed
        def parse_message(error)
          return error.message unless error.response

          parsed_json = JSON.parse(error.response.body)
          parsed_json.dig("response", "errors")&.map { |response_error| response_error["message"] }&.join(", ")
        rescue JSON::ParserError, KeyError => _e
          nil
        end
      end
    end
  end
end
