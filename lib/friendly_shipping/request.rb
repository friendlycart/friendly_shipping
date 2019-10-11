# frozen_string_literal: true

module FriendlyShipping
  class Request
    attr_reader :url, :body, :headers, :debug

    def initialize(url:, body: nil, headers: {}, debug: false)
      @url = url
      @body = body
      @headers = headers
      @debug = debug
    end
  end
end
