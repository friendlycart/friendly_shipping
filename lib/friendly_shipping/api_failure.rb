# frozen_string_literal: true

module FriendlyShipping
  class ApiFailure < ApiResult
    alias_method :failure, :data

    def to_s
      failure.to_s
    end
  end
end
