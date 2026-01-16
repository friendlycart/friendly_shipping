# frozen_string_literal: true

module FriendlyShipping
  module Services
    class G2Mint
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
          status = parsed_json['status'] || parsed_json['code']
          message = parsed_json['message'] || parsed_json['error']
          [status, message].compact.join(": ")
        rescue JSON::ParserError, KeyError => _e
          nil
        end
      end
    end
  end
end
