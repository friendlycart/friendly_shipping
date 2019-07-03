# frozen_string_literal: true

module FriendlyShipping
  class Response
    attr_reader :status, :body, :headers

    def initialize(status:, body:, headers:)
      @status = status
      @body = body
      @headers = headers
    end
  end
end
