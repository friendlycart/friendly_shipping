# frozen_string_literal: true

require 'json'

module FriendlyShipping
  module Services
    class RL
      class BadRequest < StandardError
        attr_reader :rest_error, :response

        # @param [RestClient::Exception] rest_error
        def initialize(rest_error)
          @rest_error = rest_error
          @response = rest_error.response
          super parse_json_errors || rest_error.to_s
        end

        private

        # @return [String, nil]
        def parse_json_errors
          parsed_body = JSON.parse(response.body)
          messages = parsed_body.fetch('Errors')&.map { |e| e.fetch('ErrorMessage') }
          messages&.join(', ')
        rescue JSON::ParserError, KeyError => _e
          nil
        end
      end
    end
  end
end
