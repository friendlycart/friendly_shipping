# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class ParseXMLResponse
        extend Dry::Monads::Result::Mixin
        SUCCESSFUL_RESPONSE_STATUS_CODE = '1'

        class << self
          def call(request:, response:, expected_root_tag:)
            xml = Nokogiri.XML(response.body, &:strict)

            if xml.root.nil? || xml.root.name != expected_root_tag
              wrap_failure('Invalid document', request, response)
            elsif request_successful?(xml)
              Success(xml)
            else
              wrap_failure(error_message(xml), request, response)
            end
          rescue Nokogiri::XML::SyntaxError => e
            wrap_failure(e, request, response)
          end

          private

          def request_successful?(xml)
            xml.root.at('Response/ResponseStatusCode').text == SUCCESSFUL_RESPONSE_STATUS_CODE
          end

          def error_message(xml)
            status = xml.root.at_xpath('Response/ResponseStatusDescription')&.text
            desc = xml.root.at_xpath('Response/Error/ErrorDescription')&.text
            [status, desc].compact.join(": ").presence || 'UPS could not process the request.'
          end

          def wrap_failure(failure, request, response)
            Failure(
              FriendlyShipping::ApiResult.new(
                failure,
                original_request: request,
                original_response: response
              )
            )
          end
        end
      end
    end
  end
end
