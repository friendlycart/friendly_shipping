require 'dry/monads/result'
require 'friendly_shipping/bad_request'
require 'rest-client'

module FriendlyShipping
  class RestClient
    extend Dry::Monads::Result::Mixin
    class <<self
      def get(path, headers)
        Success(
          ::RestClient.get(
            path,
            headers
          )
        )
      rescue ::RestClient::Exception => error
        Failure(error)
      end

      def post(friendly_shipping_request)
        http_response = ::RestClient.post(
          friendly_shipping_request.url,
          friendly_shipping_request.body,
          friendly_shipping_request.headers
        )
        response = FriendlyShipping::Response.new(
          status: http_response.code,
          body: http_response.body,
          headers: http_response.headers
        )
        Success(response)
      rescue ::RestClient::Exception => error
        if error.http_code == 400
          Failure(BadRequest.new(error))
        else
          Failure(error)
        end
      end

      def put(path, payload, headers)
        Success(
          ::RestClient.put(
            path,
            payload,
            headers
          )
        )
      rescue ::RestClient::Exception => error
        if error.http_code == 400
          Failure(BadRequest.new(error))
        else
          Failure(error)
        end
      end
    end
  end
end
