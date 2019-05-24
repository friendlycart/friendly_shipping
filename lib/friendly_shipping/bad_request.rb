require 'json'

module FriendlyShipping
  class BadRequest < StandardError
    attr_reader :rest_error, :response

    def initialize(rest_error)
      @rest_error = rest_error
      @response = rest_error.response
      super parse_json_errors || rest_error
    end

    private

    def parse_json_errors
      parsed_body = JSON.parse(response.body)
      messages = parsed_body.fetch('errors')&.map { |e| e.fetch('message') }
      messages&.join(', ')
    rescue JSON::ParserError, KeyError => _error
      nil
    end
  end
end
