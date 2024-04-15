# frozen_string_literal: true

require 'jwt'

module FriendlyShipping
  module Services
    class USPSShip
      # Represents an access token returned by USPS Ship. The access token can be
      # used to make API requests. Once it expires, a new token must be created.
      class AccessToken
        # @return [String] the token's type
        attr_reader :token_type

        # @return [Integer] the token's expiration
        attr_reader :expires_in

        # @return [String] the raw JWT token
        attr_reader :raw_token

        # @param token_type [String] the token's type (typically "Bearer")
        # @param expires_in [Integer] the token's expiration
        # @param raw_token [String] the raw JWT token
        def initialize(token_type:, expires_in:, raw_token:)
          @token_type = token_type
          @expires_in = expires_in
          @raw_token = raw_token
        end

        # Decodes and returns the raw JWT token.
        # @return [Array<Hash>] the decoded token
        def decoded_token
          @_decoded_token = JWT.decode(raw_token, nil, false)
        end
      end
    end
  end
end
