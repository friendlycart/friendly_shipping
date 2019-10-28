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
      @headers = headers
    end
  end
end
