# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class ShipmentInformation
        attr_reader :documents,
                    :pro_number,
                    :pickup_request_number

        def initialize(
          pro_number:,
          pickup_request_number: nil,
          documents: []
        )
          @pro_number = pro_number
          @pickup_request_number = pickup_request_number
          @documents = documents
        end

        # @return [Boolean]
        def valid?
          pro_number.present? && pickup_request_number.present?
        end
      end
    end
  end
end
