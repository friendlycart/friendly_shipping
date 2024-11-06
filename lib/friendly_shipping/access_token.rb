# frozen_string_literal: true

module FriendlyShipping
  # Represents an access token returned by a carrier.
  class AccessToken
    # @return [Integer] the token's expiration
    attr_reader :expires_in

    # @return [String] the raw token
    attr_reader :raw_token

    # @param expires_in [Integer] the token's expiration
    def initialize(expires_in:, raw_token:)
      @expires_in = expires_in
      @raw_token = raw_token
    end

    # Decodes and returns the raw token (only applicable to JWT tokens).
    # @return [Array<Hash>] the decoded token
    def decoded_token
      @_decoded_token = JWT.decode(raw_token, nil, false)
    end
  end
end
