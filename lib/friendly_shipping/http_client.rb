# frozen_string_literal: true

module FriendlyShipping
  # A façade for `RestClient` which constructs requests, wraps responses in `Dry::Monad`
  # results, and calls the API error handler with failures.
  class HttpClient
    include Dry::Monads::Result::Mixin

    # @return [.call] the API error handler
    attr_reader :error_handler

    # @param error_handler [.call] called if an API error occurs
    def initialize(error_handler: FriendlyShipping::ApiErrorHandler.new)
      @error_handler = error_handler
    end

    # Makes a GET request and handles the response.
    # @param request [Request] the request to GET
    # @return [Success<Response>, Failure<ApiResult>]
    def get(request)
      http_response = ::RestClient.get(
        request.url, request.headers
      )

      Success(Response.new_from_rest_client_response(http_response))
    rescue ::RestClient::Exception => e
      error_handler.call(e, original_request: request, original_response: e.response)
    end

    # Makes a DELETE request and handles the response.
    # @param request [Request] the request to DELETE
    # @return [Success<Response>, Failure<ApiResult>]
    def delete(request)
      http_response = ::RestClient.delete(request.url, request.headers)

      Success(Response.new_from_rest_client_response(http_response))
    rescue ::RestClient::Exception => e
      error_handler.call(e, original_request: request, original_response: e.response)
    end

    # Makes a POST request and handles the response.
    # @param request [Request] the request to POST
    # @return [Success<Response>, Failure<ApiResult>]
    def post(request)
      http_response = ::RestClient.post(
        request.url,
        request.body,
        request.headers
      )

      Success(Response.new_from_rest_client_response(http_response))
    rescue ::RestClient::Exception => e
      error_handler.call(e, original_request: request, original_response: e.response)
    end

    # Makes a PUT request and handles the response.
    # @param request [Request] the request to PUT
    # @return [Success<Response>, Failure<ApiResult>]
    def put(request)
      http_response = ::RestClient.put(
        request.url,
        request.body,
        request.headers
      )

      Success(Response.new_from_rest_client_response(http_response))
    rescue ::RestClient::Exception => e
      error_handler.call(e, original_request: request, original_response: e.response)
    end
  end
end
