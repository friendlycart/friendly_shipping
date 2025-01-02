# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Parses the response from the R+L API when printing shipping labels.
      class ParsePrintShippingLabelsResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request to attach to the API result
          # @param response [Response] the response to parse
          # @return [Result<ApiResult<ShipmentDocument>>] shipping document containing the labels
          def call(request:, response:)
            parsed_json = JSON.parse(response.body)
            label_doc = ShipmentDocument.new(
              format: :pdf,
              document_type: :label,
              binary: Base64.decode64(parsed_json['ShippingLabelsFile'])
            )
            if label_doc.valid?
              Success(
                ApiResult.new(
                  label_doc,
                  original_request: request,
                  original_response: response
                )
              )
            else
              errors = parsed_json.fetch('Errors', [{ 'ErrorMessage' => 'Unknown error' }])
              Failure(
                ApiResult.new(
                  errors.map { |e| e['ErrorMessage'] },
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
end
