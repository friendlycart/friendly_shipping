# frozen_string_literal: true

require 'jwt'

module FriendlyShipping
  module Services
    class TForceFreight
      # Represents an access token returned by TForce Freight. The access token can be
      # used to make API requests. Once it expires, a new token must be created.
      class AccessToken < FriendlyShipping::AccessToken
        # @return [String] the token's type
        attr_reader :token_type

        # @return [Integer] the token's extended expiration
        attr_reader :ext_expires_in

        # @param token_type [String] the token's type (typically "Bearer")
        # @param ext_expires_in [Integer] the token's extended expiration (only applicable during a service outage)
        # @see https://github.com/AzureAD/azure-activedirectory-library-for-android/issues/675 Service Outage Resiliency Support
        def initialize(token_type:, ext_expires_in:, **other_kwargs)
          @token_type = token_type
          @ext_expires_in = ext_expires_in
          super(**other_kwargs)
        end
      end
    end
  end
end
