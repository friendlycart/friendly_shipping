# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class ParseJSONResponse
        extend Dry::Monads::Result::Mixin

        class << self
          def call(response_body, expected_root_tag)
            json = JSON.parse(response_body)

            if request_successful?(json, expected_root_tag)
              Success(json)
            else
              Failure(error_message(json))
            end
          rescue JSON::ParserError => e
            Failure(e)
          end

          private

          def request_successful?(json, expected_root_tag)
            json[expected_root_tag].present?
          end

          def error_message(json)
            detailed_error = json.dig('Fault', 'detail', 'Errors', 'ErrorDetail', 'PrimaryErrorCode')
            status = detailed_error['Code']
            desc = detailed_error['Description']
            [status, desc].compact.join(": ").presence || 'UPS could not process the request.'
          end
        end
      end
    end
  end
end
