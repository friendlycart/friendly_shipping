# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Represents an access token returned by UPS. The access token can be used to make API requests.
      # Once it expires, a new token must be created.
      class AccessToken
        # @return [Integer] the token's expiration
        attr_reader :expires_in

        # @return [Integer] the epoch time in ms when the token was issued
        attr_reader :issued_at

        # @return [String] the raw JWT token
        attr_reader :raw_token

        # @param expires_in [Integer] the token's expiration
        # @param issued_at [Integer] the time the token was issued at
        # @param raw_token [String] the raw JWT token
        def initialize(expires_in:, issued_at:, raw_token:)
          @expires_in = expires_in
          @issued_at = issued_at
          @raw_token = raw_token
        end
      end
    end
  end
end
