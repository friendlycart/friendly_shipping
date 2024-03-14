# frozen_string_literal: true

module FriendlyShipping
  # Wraps an API result from a request that failed.
  class ApiFailure < ApiResult
    # @!attribute [r] data
    #   The API failure (typically an exception)
    alias_method :failure, :data

    # @return [#to_s] a string representation of the failure
    def to_s
      failure.to_s
    end
  end
end
