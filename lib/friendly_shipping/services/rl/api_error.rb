# frozen_string_literal: true

require 'friendly_shipping/api_error'

module FriendlyShipping
  module Services
    class RL
      class ApiError < FriendlyShipping::ApiError
        # @param [RestClient::Exception] cause
        def initialize(cause)
          super cause, parse_message(cause)
        end

        private

        # @param [RestClient::Exception] error
        # @return [String, nil]
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
