# frozen_string_literal: true

require 'json'

module FriendlyShipping
  module Services
    class ShipEngine
      class ParseAddressValidationResponse
        extend Dry::Monads::Result::Mixin

        class << self
          # @param [FriendlyShipping::Request] request
          # @param [FriendlyShipping::Response] response
          # @return [Success<ApiResult<Array<Physical::Location>>>, Failure<ApiResult>]
          def call(request:, response:)
            parsed_json = JSON.parse(response.body)
            if parsed_json.first['status'] == "error"
              errors = parsed_json.first['messages'].map { |message| message['message'] }.join(", ")
              Failure(
                ApiResult.new(
                  errors,
                  original_request: request,
                  original_response: response
                )
              )
            else
              locations = parsed_json.map do |result|
                address = result['matched_address']
                Physical::Location.new(
                  name: address['name'],
                  email: address['email'],
                  phone: address['phone'],
                  company_name: address['company_name'],
                  address1: address['address_line1'],
                  address2: address['address_line2'],
                  address3: address['address_line3'],
                  city: address['city_locality'],
                  zip: address['postal_code'],
                  region: address['state_province'],
                  country: address['country_code'],
                  address_type: address_type(address)
                )
              end
              Success(
                ApiResult.new(
                  locations,
                  original_request: request,
                  original_response: response
                )
              )
            end
          rescue JSON::ParserError => e
            Failure(
              FriendlyShipping::ApiResult.new(
                e,
                original_request: request,
                original_response: response
              )
            )
          end

          private

          # @param address [Hash]
          # @return [String]
          def address_type(address)
            case address['address_residential_indicator']
            when "yes" then "residential"
            when "no" then "commercial"
            else "unknown"
            end
          end
        end
      end
    end
  end
end
