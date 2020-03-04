# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      class ParseXMLResponse
        extend Dry::Monads::Result::Mixin
        ERROR_TAG = 'Error'

        class << self
          def call(request:, response:, expected_root_tag:)
            xml = Nokogiri.XML(response.body, &:strict)

            if xml.root.nil? || ![expected_root_tag, 'Error'].include?(xml.root.name)
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
            xml.xpath('//Error/Number')&.text.blank?
          end

          def error_message(xml)
            number = xml.xpath('//Error/Number')&.text
            desc = xml.xpath('//Error/Description')&.text
            [number, desc].select(&:present?).join(': ').presence&.strip || 'USPS could not process the request.'
          end

          def wrap_failure(failure, request, response)
            Failure(
              FriendlyShipping::ApiFailure.new(
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
