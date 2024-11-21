# frozen_string_literal: true

module FriendlyShipping
  # Raised when an API error is returned. Parent of carrier-specific API error classes.
  class ApiError < StandardError
    # @return [RestClient::Exception] the cause of the error
    attr_reader :cause

    # @param cause [RestClient::Exception, nil] the cause of the error
    # @param message [String] optional descriptive message
    def initialize(cause, message = nil)
      raise ArgumentError, "Must provide either a cause or a message" if cause.nil? && message.nil?

      @cause = cause
      super(message || cause&.message)
    end
  end
end
