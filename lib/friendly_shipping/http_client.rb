# frozen_string_literal: true

require 'dry/monads/result'
require 'rest-client'

require 'friendly_shipping/api_failure'
require 'friendly_shipping/api_error_handler'

module FriendlyShipping
  class HttpClient
    include Dry::Monads::Result::Mixin

    attr_reader :error_handler

    # @param [Proc] error_handler Called to handle an error if one occurs
    def initialize(error_handler: FriendlyShipping::ApiErrorHandler.new)
      @error_handler = error_handler
    end

    def get(request)
      http_response = ::RestClient.get(
        request.url, request.headers
      )

      Success(convert_to_friendly_response(http_response))
    rescue ::RestClient::Exception => e
      error_handler.call(e, original_request: request, original_response: e.response)
    end

    def post(request)
      http_response = ::RestClient.post(
        request.url,
        request.body,
        request.headers
      )

      Success(convert_to_friendly_response(http_response))
    rescue ::RestClient::Exception => e
      error_handler.call(e, original_request: request, original_response: e.response)
    end

    def put(request)
      http_response = ::RestClient.put(
        request.url,
        request.body,
        request.headers
      )

      Success(convert_to_friendly_response(http_response))
    rescue ::RestClient::Exception => e
      error_handler.call(e, original_request: request, original_response: e.response)
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
