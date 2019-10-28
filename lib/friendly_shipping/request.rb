# frozen_string_literal: true

module FriendlyShipping
  class Request
    attr_reader :url, :body, :headers, :debug

    # @param [String] url The HTTP request URL
    # @param [String] body The HTTP request body
    # @param [Hash] headers The HTTP request headers
    # @param [Boolean] debug Whether to debug the request
    def initialize(url:, body: nil, headers: {}, debug: false)
      @url = url
      @body = body
      @headers = headers
      @debug = debug
    end
  end
end
