# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UspsInternational
      # Parses the XML envelope of a USPS international response and detects errors
      class ParseXMLResponse
        extend Dry::Monads::Result::Mixin

        # The tag USPS uses to report errors
        ERROR_TAG = 'Error'

        class << self
          # @param request [Request] the request that was used to obtain this response
          # @param response [Response] the response that USPS returned
          # @param expected_root_tag [String] the root tag a successful response must have
          # @return [Success<Nokogiri::XML::Document>, Failure<ApiResult>]
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

          # @param xml [Nokogiri::XML::Document]
          # @return [Boolean]
          def request_successful?(xml)
            xml.xpath('//Error/Number')&.text.blank?
          end

          # @param xml [Nokogiri::XML::Document]
          # @return [String]
          def error_message(xml)
            number = xml.xpath('//Error/Number')&.text
            desc = xml.xpath('//Error/Description')&.text
            [number, desc].select(&:present?).join(': ').presence&.strip || 'USPS could not process the request.'
          end

          # @param failure [String, Exception] the failure reason
          # @param request [Request]
          # @param response [Response]
          # @return [Failure<ApiResult>]
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
