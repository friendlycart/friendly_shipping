# frozen_string_literal: true

require 'json'
require 'friendly_shipping/services/rl/shipment_document'

module FriendlyShipping
  module Services
    class RL
      class ParseInvoiceResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param [FriendlyShipping::Request] request
          # @param [FriendlyShipping::Response] response
          # @return [Result<ApiResult<ShipmentDocument>>]
          def call(request:, response:)
            parsed_json = JSON.parse(response.body)
            data = (parsed_json['Documents'].find { _1["Type"] == "Invoice" } || {})["Data"]

            document = ShipmentDocument.new(binary: data, format: :pdf, document_type: :invoice)
            if document.valid?
              Success(
                ApiResult.new(
                  document,
                  original_request: request,
                  original_response: response
                )
              )
            else
              errors = if parsed_json["Messages"].present?
                         parsed_json["Messages"]
                       else
                         parsed_json.fetch('Errors', [{ 'ErrorMessage' => 'Unknown error' }]).
                           map { _1['ErrorMessage'] }
                       end

              Failure(
                ApiResult.new(
                  errors,
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
