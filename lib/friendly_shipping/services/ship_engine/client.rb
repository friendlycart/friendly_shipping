# frozen_string_literal: true

require 'dry/monads/result'
require 'friendly_shipping/bad_request'
require 'rest-client'

module FriendlyShipping
  module Services
    class ShipEngine
      class Client
        extend Dry::Monads::Result::Mixin
        class <<self
          def get(request)
            http_response = ::RestClient.get(
              request.url, request.headers
            )

            Success(convert_to_friendly_response(http_response))
          rescue ::RestClient::Exception => e
            Failure(e)
          end

          def post(friendly_shipping_request)
            http_response = ::RestClient.post(
              friendly_shipping_request.url,
              friendly_shipping_request.body,
              friendly_shipping_request.headers
            )

            Success(convert_to_friendly_response(http_response))
          rescue ::RestClient::Exception => e
            if e.http_code == 400
              Failure(BadRequest.new(e))
            else
              Failure(e)
            end
          end

          def put(request)
            http_response = ::RestClient.put(
              request.url,
              request.body,
              request.headers
            )

            Success(convert_to_friendly_response(http_response))
          rescue ::RestClient::Exception => e
            if e.http_code == 400
              Failure(BadRequest.new(e))
            else
              Failure(e)
            end
          end

          private

          def convert_to_friendly_response(http_response)
            FriendlyShipping::Response.new(
              status: http_response.code,
              body: http_response.body,
              headers: http_response.headers
            )
          end
        end
      end
    end
  end
end
