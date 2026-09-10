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

        # Parses the message from the error response. R+L returns its error envelope
        # for server errors as well as bad requests (cancelling a pickup in a status
        # that can't be cancelled comes back as a 500), so any parseable body is used.
        #
        # @param error [RestClient::Exception] the cause of the error
        # @return [String, nil] the message or nil if it couldn't be parsed
        def parse_message(error)
          return error.message unless error.response

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
