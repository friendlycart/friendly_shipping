# frozen_string_literal: true

module FriendlyShipping
  class Response
    attr_reader :status, :body, :headers

    # @param [Integer] status The HTTP response status code
    # @param [String] body The HTTP response body
    # @param [Hash] headers The HTTP response headers
    def initialize(status:, body:, headers:)
      @status = status
      @body = body
      @headers = headers || {}
    end

    # @param [RestClient::Response] response
    # @return [FriendlyShipping::Response]
    def self.new_from_rest_client_response(response)
      new(status: response&.code, body: response&.body, headers: response&.headers)
    end

    # @param [Object] other
    def ==(other)
      other.class == self.class &&
        other.attributes == attributes
    end

    alias_method :eql?, :==

    def hash
      attributes.hash
    end

    protected

    def attributes
      [status, body, headers]
    end
  end
end
