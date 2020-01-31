# frozen_string_literal: true

module FriendlyShipping
  class Request
    attr_reader :url, :body, :headers, :debug

    # @param [String] url The HTTP request URL
    # @param [String] body The HTTP request body
    # # @param [String] readable_body Human-readable HTTP request body
    # @param [Hash] headers The HTTP request headers
    # @param [Boolean] debug Whether to debug the request
    def initialize(url:, body: nil, readable_body: nil, headers: {}, debug: false)
      @url = url
      @body = body
      @readable_body = readable_body
      @headers = headers
      @debug = debug
    end

    def readable_body
      @readable_body.presence || @body
    end
  end
end
