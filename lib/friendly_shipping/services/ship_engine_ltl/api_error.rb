# frozen_string_literal: true

require 'friendly_shipping/services/ship_engine/api_error'

module FriendlyShipping
  module Services
    class ShipEngineLTL
      # Raised when an API error is returned.
      class ApiError < FriendlyShipping::Services::ShipEngine::ApiError
        # not implemented
      end
    end
  end
end
