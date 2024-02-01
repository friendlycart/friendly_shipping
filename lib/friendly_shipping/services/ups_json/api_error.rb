# frozen_string_literal: true

require 'friendly_shipping/api_error'

module FriendlyShipping
  module Services
    class UpsJson
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
          parsed_json.dig("response", "errors").join(", ")
        rescue JSON::ParserError, KeyError => _e
          nil
        end
      end
    end
  end
end
