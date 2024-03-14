# frozen_string_literal: true

require 'friendly_shipping/api_error'

module FriendlyShipping
  module Services
    class ShipEngine
      # Raised when an API error is returned.
      class ApiError < FriendlyShipping::ApiError
        # @param cause [RestClient::Exception] the cause of the error
        def initialize(cause)
          super(cause, parse_message(cause))
        end

        private

        # Parses the message from the error response.
        #
        # @param error [RestClient::Exception] the cause of the error
        # @return [String, nil] the message or nil if it couldn't be parsed
        def parse_message(error)
          return error.message unless error.response && error.http_code == 400

          parsed_body = JSON.parse(error.response.body)
          messages = parsed_body.fetch('errors')&.map { |e| e.fetch('message') }
          messages&.join(', ')
        rescue JSON::ParserError, KeyError => _e
          nil
        end
      end
    end
  end
end
