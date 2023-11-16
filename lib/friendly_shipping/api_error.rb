# frozen_string_literal: true

module FriendlyShipping
  class ApiError < StandardError
    attr_reader :cause

    # @param [RestClient::Exception] cause
    # @param [String] message
    def initialize(cause, message = nil)
      @cause = cause
      super message || cause.message
    end
  end
end
