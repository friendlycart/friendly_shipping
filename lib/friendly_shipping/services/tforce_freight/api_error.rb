# frozen_string_literal: true

require 'friendly_shipping/api_error'

module FriendlyShipping
  module Services
    class TForceFreight
      class ApiError < FriendlyShipping::ApiError
        # @param [RestClient::Exception] cause
        def initialize(cause)
          super(cause, parse_message(cause))
        end

        private

        # @param [RestClient::Exception] error
        # @return [String]
        def parse_message(error)
          return error.message unless error.response

          parsed_json = JSON.parse(error.response.body)
          if parsed_json['summary'].present?
            status = parsed_json.dig("summary", "responseStatus", "code")
            message = parsed_json.dig("summary", "responseStatus", "message")
          else
            status = parsed_json['statusCode']
            message = parsed_json['message']
          end
          [status, message].compact.join(": ")
        rescue JSON::ParserError, KeyError => _e
          nil
        end
      end
    end
  end
end
