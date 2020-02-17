# frozen_string_literal: true

module FriendlyShipping
  class Request
    attr_reader :url, :http_method, :body, :headers, :open_timeout, :read_timeout, :debug

    # @param [String] url The HTTP request URL
    # @param [String] http_method The HTTP request method
    # @param [String] body The HTTP request body
    # @param [String] readable_body Human-readable HTTP request body
    # @param [Hash] headers The HTTP request headers
    # @param [Integer] open_timeout The HTTP open timeout in seconds
    # @param [Integer] read_timeout The HTTP read timeout in seconds
    # @param [Boolean] debug Whether to debug the request
    def initialize(url:, http_method: nil, body: nil, readable_body: nil, headers: {}, open_timeout: nil, read_timeout: nil, debug: false)
      @url = url
      @http_method = http_method
      @body = body
      @readable_body = readable_body
      @headers = headers
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @debug = debug
    end

    def readable_body
      @readable_body.presence || @body
    end
  end
end
