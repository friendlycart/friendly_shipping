# frozen_string_literal: true

module FriendlyShipping
  class ApiFailure
    attr_reader :failure, :original_request, :original_response

    # @param [Object] failure The API failure
    # @param [FriendlyShipping::Request] original_request The HTTP request (when debugging is enabled)
    # @param [FriendlyShipping::Response] original_response The HTTP response (when debugging is enabled)
    def initialize(failure, original_request:, original_response:)
      @failure = failure

      # We do not want to attach debugging information in every single response to save memory in production
      return unless original_request&.debug

      @original_request = original_request
      @original_response = original_response
    end

    def to_s
      failure.to_s
    end
  end
end
