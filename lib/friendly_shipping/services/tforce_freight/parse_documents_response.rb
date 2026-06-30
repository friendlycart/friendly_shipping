# frozen_string_literal: true

require "base64"

module FriendlyShipping
  module Services
    class TForceFreight
      # Parses a get documents by PRO response into an `ApiResult`.
      class ParseDocumentsResponse
        extend Dry::Monads::Result::Mixin

        # Maps document category codes to friendly names.
        REVERSE_DOCUMENT_CATEGORIES = GenerateDocumentsRequestHash::DOCUMENT_CATEGORIES.map(&:reverse_each).to_h(&:to_a)

        # The response status code that indicates success. The Documents API returns
        # HTTP 200 even for errors, so success must be determined from the body.
        SUCCESS_CODE = "1"

        class << self
          # @param request [Request] the original request
          # @param response [RestClient::Response] the response to parse
          # @return [Result<ApiResult<Array<ShipmentDocument>>>] the parsed documents on success,
          #   or a failure containing the error message
          def call(request:, response:)
            json = JSON.parse(response.body)
            status_code = json.dig("summary", "responseStatus", "code")

            unless status_code == SUCCESS_CODE
              message = json.dig("summary", "responseStatus", "message")
              return Failure(
                ApiResult.new(
                  [status_code, message].compact.join(": "),
                  original_request: request,
                  original_response: response
                )
              )
            end

            documents = json.fetch("detail", []).compact.map do |detail|
              category = detail["category"]
              ShipmentDocument.new(
                document_type: REVERSE_DOCUMENT_CATEGORIES.fetch(category, category),
                document_format: :pdf,
                status: detail.dig("detailStatus", "documentStatus"),
                binary: Base64.decode64(detail["data"])
              )
            end

            Success(
              ApiResult.new(
                documents,
                original_request: request,
                original_response: response
              )
            )
          end
        end
      end
    end
  end
end
