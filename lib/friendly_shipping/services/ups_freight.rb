# frozen_string_literal: true

require 'dry/monads/result'
require 'friendly_shipping/http_client'
require 'friendly_shipping/services/ups_freight/shipping_methods'

module FriendlyShipping
  module Services
    class UpsFreight
      include Dry::Monads::Result::Mixin

      attr_reader :test, :key, :login, :password, :client

      CARRIER = FriendlyShipping::Carrier.new(
        id: 'ups_freight',
        name: 'United Parcel Service LTL',
        code: 'ups-freight',
        shipping_methods: SHIPPING_METHODS
      )

      def initialize(key:, login:, password:, test: true, client: HttpClient.new)
        @key = key
        @login = login
        @password = password
        @test = test
        @client = client
      end

      def carriers
        Success([CARRIER])
      end
    end
  end
end
