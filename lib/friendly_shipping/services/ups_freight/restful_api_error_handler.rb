# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class RestfulApiErrorHandler
        extend Dry::Monads::Result::Mixin

        # Handles error responses from the API by parsing the JSON body and returning an
        # object. HTTP errors and API failures each use a different JSON structure. For
        # example, an HTTP error response looks like this:
        #
        # {
        #   "httpCode": "400",
        #   "httpMessage": "Bad Request",
        #   "moreInformation": "The body of the request, which was expected to be JSON, was invalid."
        # }
        #
        # Whereas an API failure looks like this:
        #
        # {
        #     "response": {
        #         "errors": [
        #             {
        #                 "code": "9360061",
        #                 "message": "Missing Ship To."
        #             }
        #         ]
        #     }
        # }
        #
        # This error handler is capable of parsing either response.
        #
        # @param [RestClient::Exception] error
        # @param [Object] original_request
        # @param [Object] original_response
        # @return [Dry::Monads::Failure<FriendlyShipping::ApiFailure>]
        def self.call(error, original_request: nil, original_response: nil)
          parsed_json = JSON.parse(error.response.body)

          if parsed_json['httpCode'].present?
            status = [parsed_json['httpCode'], parsed_json['httpMessage']].compact.join(" ")
            desc = parsed_json['moreInformation']
            failure_string = [status, desc].compact.join(": ")
          else
            errors = parsed_json.dig('response', 'errors') || []
            failure_string = errors.map do |err|
              status = err['code']
              desc = err['message']
              [status, desc].compact.join(": ").presence || 'UPS could not process the request.'
            end.join("\n")
          end

          Failure(
            ApiFailure.new(
              failure_string,
              original_request: original_request,
              original_response: original_response
            )
          )
        end
      end
    end
  end
end
