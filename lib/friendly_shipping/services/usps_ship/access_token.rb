# frozen_string_literal: true

require 'jwt'

module FriendlyShipping
  module Services
    class USPSShip
      # Represents an access token returned by USPS Ship. The access token can be
      # used to make API requests. Once it expires, a new token must be created.
      class AccessToken < FriendlyShipping::AccessToken
        # @return [String] the token's type
        attr_reader :token_type

        # @param token_type [String] the token's type (typically "Bearer")
        def initialize(token_type:, **other_kwargs)
          @token_type = token_type
          super(**other_kwargs)
        end
      end
    end
  end
end
