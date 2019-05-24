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
      rescue ::RestClient::ExceptionWithResponse => error
        Failure(error)
      end

      def post(path, payload, headers)
        Success(
          ::RestClient.post(
            path,
            payload,
            headers
          )
        )
      rescue ::RestClient::ExceptionWithResponse => error
        if error.to_s == '400 Bad Request'
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
      rescue ::RestClient::ExceptionWithResponse => error
        if error.to_s == '400 Bad Request'
          Failure(BadRequest.new(error))
        else
          Failure(error)
        end
      end
    end
  end
end
