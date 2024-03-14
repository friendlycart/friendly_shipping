# frozen_string_literal: true

module FriendlyShipping
  # Represents an HTTP request sent to a carrier API.
  class Request
    # @return [String] the HTTP request URL
    attr_reader :url

    # @return [String] the HTTP request method
    attr_reader :http_method

    # @return [String] the HTTP request body
    attr_reader :body

    # @return [String] human-readable HTTP request body
    attr_reader :headers

    # @return [Boolean] whether to attach debugging information to the response
    attr_reader :debug

    # @param url [String] the HTTP request URL
    # @param http_method [String] the HTTP request method
    # @param body [String] the HTTP request body
    # @param readable_body [String] human-readable HTTP request body
    # @param headers [Hash] the HTTP request headers
    # @param debug [Boolean] whether to attach debugging information to the response
    def initialize(url:, http_method: nil, body: nil, readable_body: nil, headers: {}, debug: false)
      @url = url
      @http_method = http_method
      @body = body
      @readable_body = readable_body
      @headers = headers
      @debug = debug
    end

    # Returns the HTTP request body.
    # @return [String] human-readable HTTP request body
    def readable_body
      @readable_body.presence || @body
    end
  end
end
