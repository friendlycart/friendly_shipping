# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Parses the response from the R+L API when printing a Bill of Lading (BOL).
      class ParsePrintBOLResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param request [Request] the request to attach to the API result
          # @param response [Response] the response to parse
          # @return [Result<ApiResult<ShipmentDocument>>] shipment document containing the BOL
          def call(request:, response:)
            parsed_json = JSON.parse(response.body)
            bol_document = ShipmentDocument.new(
              format: :pdf,
              document_type: :rl_bol,
              binary: Base64.decode64(parsed_json['BolDocument'])
            )
            if bol_document.valid?
              Success(
                ApiResult.new(
                  bol_document,
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
