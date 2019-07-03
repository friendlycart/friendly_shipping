# frozen_string_literal: true

module FriendlyShipping
  class Request
    attr_reader :url, :body, :headers

    def initialize(url:, body: nil, headers: {})
      @url = url
      @body = body
      @headers = headers
    end
  end
end
