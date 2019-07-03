require 'dry/monads/result'
require 'friendly_shipping/services/ups/client'
require 'friendly_shipping/services/ups/serialize_access_request'
require 'friendly_shipping/services/ups/serialize_rating_service_selection_request'
require 'friendly_shipping/services/ups/parse_rate_response'
require 'friendly_shipping/services/ups/shipping_methods'

module FriendlyShipping
  module Services
    class Ups
      include Dry::Monads::Result::Mixin

      attr_reader :test, :key, :login, :password, :client

      CARRIER = FriendlyShipping::Carrier.new(
        id: 'ups',
        name: 'United Parcel Service',
        code: 'ups',
        shipping_methods: SHIPPING_METHODS
      )

      TEST_URL = 'https://wwwcie.ups.com'
      LIVE_URL = 'https://onlinetools.ups.com'

      RESOURCES = {
        rates: '/ups.app/xml/Rate'
      }

      def initialize(key:, login:, password:, test: true, client: Client)
        @key = key
        @login = login
        @password = password
        @test = test
        @client = client
      end

      def carriers
        Success([CARRIER])
      end

      def rate_estimates(shipment, carriers)
        rate_request_xml = SerializeRatingServiceSelectionRequest.(shipment: shipment)
        url = base_url + RESOURCES[:rates]
        request = FriendlyShipping::Request.new(
          url: url,
          body: access_request_xml + rate_request_xml
        )

        client.post(request).bind do |response|
          ParseRateResponse.(response: response, request: request, shipment: shipment)
        end
      end

      private

      def access_request_xml
        SerializeAccessRequest.(key: key, login: login, password: password)
      end

      def base_url
        test ? TEST_URL : LIVE_URL
      end
    end
  end
end
