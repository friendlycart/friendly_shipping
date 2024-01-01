# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Wraps errors returned by the UPS Freight API, extracting a readable message from the response body.
      class ApiError < FriendlyShipping::ApiError
        # @param cause [RestClient::Exception] the underlying HTTP error
        def initialize(cause)
          super(cause, parse_message(cause))
        end

        private

        # @param error [RestClient::Exception] the underlying HTTP error
        # @return [String, nil] the message, or nil if the response body could not be parsed
        def parse_message(error)
          return error.message unless error.response

          parsed_json = JSON.parse(error.response.body)

          if parsed_json['httpCode'].present?
            status = [parsed_json['httpCode'], parsed_json['httpMessage']].compact.join(" ")
            desc = parsed_json['moreInformation']
            [status, desc].compact.join(": ")
          else
            errors = parsed_json.dig('response', 'errors') || []
            errors.map do |err|
              status = err['code']
              desc = err['message']
              [status, desc].compact.join(": ").presence || "UPS Freight could not process the request."
            end.join("\n")
          end
        rescue JSON::ParserError, KeyError => _e
          nil
        end
      end
    end
  end
end
