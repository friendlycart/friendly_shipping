# frozen_string_literal: true

module FriendlyShipping
  class ApiResult
    attr_reader :data, :original_request, :original_response

    def initialize(data, original_request: nil, original_response: nil)
      @data = data

      # We do not want to attach debugging information in every single response to save memory in production
      return unless original_request&.debug

      @original_request = original_request
      @original_response = original_response
    end
  end
end
