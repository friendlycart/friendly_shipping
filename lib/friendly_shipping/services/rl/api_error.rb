# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Raised when an R+L API error is returned.
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
          messages = parsed_body.fetch('Errors')&.map { |e| e.fetch('ErrorMessage') }
          messages&.join(', ')
        rescue JSON::ParserError, KeyError => _e
          nil
        end
      end
    end
  end
end
