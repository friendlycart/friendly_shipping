# frozen_string_literal: true

require 'json'
require 'friendly_shipping/services/rl/shipment_document'

module FriendlyShipping
  module Services
    class RL
      class ParsePrintBOLResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param [FriendlyShipping::Request] request
          # @param [FriendlyShipping::Response] response
          # @return [Dry::Monads::Result<ApiResult<ShipmentDocument>>]
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
