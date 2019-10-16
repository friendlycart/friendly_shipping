# frozen_string_literal: true

require 'dry/monads/result'
require 'rest-client'

module FriendlyShipping
  module Services
    class Ups
      class Client
        extend Dry::Monads::Result::Mixin
        class << self
          def post(friendly_shipping_request)
            http_response = ::RestClient.post(
              friendly_shipping_request.url,
              friendly_shipping_request.body,
              friendly_shipping_request.headers
            )

            Success(convert_to_friendly_response(http_response))
          rescue ::RestClient::Exception => e
            Failure(e)
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
