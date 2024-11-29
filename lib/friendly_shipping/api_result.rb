# frozen_string_literal: true

module FriendlyShipping
  # Wraps an API result (a response body, for example) along with the
  # original request and response objects.
  class ApiResult
    # @return [Object] the API result (typically the response body)
    attr_reader :data

    # @!attribute [r] data
    #   The API failure (typically an exception). This is here to maintain
    #   backwards compatibility with the old {ApiFailure} class.
    alias_method :failure, :data

    # @return [Request] the original API request (if debugging is enabled)
    attr_reader :original_request

    # @return [Response] the original API response (if debugging is enabled)
    attr_reader :original_response

    # Returns a new instance of `ApiResult`. The original request and response are only attached
    # to this object if debugging is enabled. See {FriendlyShipping::Request#debug}
    #
    # @param data [Object] the API result (typically the response body)
    # @param original_request [Request] the original API request
    # @param original_response [Response] the original API response
    def initialize(data, original_request: nil, original_response: nil)
      @data = data

      # We do not want to attach debugging information in every single response to save memory in production
      return unless original_request&.debug

      @original_request = original_request
      @original_response = original_response
    end

    # @return [#to_s] a string representation of the data
    def to_s
      data.to_s
    end
  end
end
