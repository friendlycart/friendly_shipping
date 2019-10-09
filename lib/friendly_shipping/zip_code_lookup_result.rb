# frozen_string_literal: true

module FriendlyShipping
  class ZipCodeLookupResult
    attr_reader :location,
                :original_location,
                :original_request,
                :original_response

    def initialize(
      location: nil,
      original_location: nil,
      original_request: nil,
      original_response: nil
    )
      @location = location
      @original_location = original_location
      @original_request = original_request
      @original_response = original_response
    end
  end
end
