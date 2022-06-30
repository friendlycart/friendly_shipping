# frozen_string_literal: true

module FriendlyShipping
  class ApiError < StandardError
    attr_reader :cause

    # @param [RestClient::Exception] cause
    # @param [String] msg
    def initialize(cause, msg = nil)
      @cause = cause
      super msg
    end
  end
end
