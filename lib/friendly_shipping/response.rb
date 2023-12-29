# frozen_string_literal: true

module FriendlyShipping
  # Represents an HTTP response received from a carrier API.
  class Response
    # @return [Integer] the HTTP response status code
    attr_reader :status

    # @return [String] the HTTP response body
    attr_reader :body

    # @return [Hash] the HTTP response headers
    attr_reader :headers

    # @param status [Integer] the HTTP response status code
    # @param body [String] the HTTP response body
    # @param headers [Hash] the HTTP response headers
    def initialize(status:, body:, headers:)
      @status = status
      @body = body
      @headers = headers || {}
    end

    alias_method :code, :status

    # Constructs a new {Response} from a `RestClient::Response` object.
    # @param response [RestClient::Response] the response to use
    # @return [Response]
    def self.new_from_rest_client_response(response)
      new(status: response&.code, body: response&.body, headers: response&.headers)
    end

    # Returns true if the given object shares the same class and attributes with this response.
    # @param [Object] other
    # @return [Boolean]
    def ==(other)
      other.class == self.class &&
        other.attributes == attributes
    end

    alias_method :eql?, :==

    # Returns this response's attributes as a hash.
    # @return [Hash]
    def hash
      attributes.hash
    end

    protected

    # Returns the status, body, and headers from this response.
    # @return [Array]
    def attributes
      [status, body, headers]
    end
  end
end
