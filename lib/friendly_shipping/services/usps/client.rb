# frozen_string_literal: true

require 'dry/monads/result'
require 'friendly_shipping/bad_request'
require 'rest-client'

module FriendlyShipping
  module Services
    class Usps
      class Client
        extend Dry::Monads::Result::Mixin
        class <<self
          # USPS allows both GET and POST request. We're using POST here as those request
          # are less limited in size.
          def post(request)
            http_response = ::RestClient.post(request.url, request.body)

            Success(convert_to_friendly_response(http_response))
          rescue ::RestClient::Exception => e
            Failure(e)
          end

          private

          def convert_to_friendly_response(http_response)
            FriendlyShipping::Response.new(
              status: http_response.code,
              body: http_response.body,
              headers: http_response.headers
            )
          end
        end
      end
    end
  end
end
