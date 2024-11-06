# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Represents an access token returned by UPS. The access token can be used to make API requests.
      # Once it expires, a new token must be created.
      class AccessToken < FriendlyShipping::AccessToken
        # @return [Integer] the epoch time in ms when the token was issued
        attr_reader :issued_at

        # @param issued_at [Integer] the time the token was issued at
        def initialize(issued_at:, **other_kwargs)
          @issued_at = issued_at
          super(**other_kwargs)
        end
      end
    end
  end
end
