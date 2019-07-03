# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class ParseXMLResponse
        extend Dry::Monads::Result::Mixin
        SUCCESSFUL_RESPONSE_STATUS_CODE = '1'

        class << self
          def call(response_body, expected_root_tag)
            xml = Nokogiri.XML(response_body)
            if xml.root.nil? || xml.root.name != expected_root_tag
              Failure('Invalid document')
            end
            if request_successful?(xml)
              Success(xml)
            else
              Failure(error_message(xml))
            end
          rescue Nokogiri::XML::SyntaxError => e
            Failure(e)
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
        end
      end
    end
  end
end
