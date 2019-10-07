# frozen_string_literal: true

module FriendlyShipping
  class AddressValidationResult
    attr_reader :suggestions,
                :original_address,
                :original_request,
                :original_response

    def initialize(
      suggestions: [],
      original_address: nil,
      original_request: nil,
      original_response: nil
    )
      @suggestions = suggestions
      @original_address = original_address
      @original_request = original_request
      @original_response = original_response
    end
  end
end
