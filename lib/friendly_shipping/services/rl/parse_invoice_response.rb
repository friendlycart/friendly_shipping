# frozen_string_literal: true

require 'json'
require 'friendly_shipping/services/rl/shipping_document'

module FriendlyShipping
  module Services
    class RL
      class ParseInvoiceResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param [FriendlyShipping::Request] request
          # @param [FriendlyShipping::Response] response
          # @return [Dry::Monads::Result<ApiResult<ShippingDocument>>]
          def call(request:, response:)
            parsed_json = JSON.parse(response.body)
            document = ShippingDocument.new(binary: parsed_json['Documents'].first['Data'])
            if document.valid?
              Success(
                ApiResult.new(
                  document,
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
