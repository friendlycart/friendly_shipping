# frozen_string_literal: true

require 'friendly_shipping/api_error'

module FriendlyShipping
  module Services
    class TForceFreight
      # Raised when an API error is returned.
      class ApiError < FriendlyShipping::ApiError
        # @param cause [RestClient::Exception]
        def initialize(cause)
          super(cause, parse_message(cause))
        end

        private

        # @param error [RestClient::Exception]
        # @return [String]
        def parse_message(error)
          return error.message unless error.response

          parsed_json = JSON.parse(error.response.body)
          if parsed_json['summary'].present?
            status = parsed_json.dig("summary", "responseStatus", "code")
            message = parsed_json.dig("summary", "responseStatus", "message").presence ||
                      parsed_json.dig("summary", "responseStatus", "description")
          else
            status = parsed_json['statusCode']
            message = parsed_json['message'].presence ||
                      parsed_json['description']
          end
          [status, message].compact.join(": ")
        rescue JSON::ParserError, KeyError => _e
          nil
        end
      end
    end
  end
end
