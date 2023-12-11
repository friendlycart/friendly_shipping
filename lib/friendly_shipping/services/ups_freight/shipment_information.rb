# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class ShipmentInformation
        attr_reader :documents,
                    :pro_number,
                    :pickup_request_number,
                    :total,
                    :bol_id,
                    :shipping_method,
                    :warnings,
                    :data

        # Backwards compatibility after renaming this attribute
        alias_method :number, :pro_number

        def initialize(
          total:,
          bol_id:,
          number: nil,
          pro_number: nil,
          pickup_request_number: nil,
          documents: [],
          shipping_method: nil,
          warnings: nil,
          data: {}
        )
          @total = total
          @bol_id = bol_id
          @pro_number = pro_number || number
          @pickup_request_number = pickup_request_number
          @documents = documents
          @shipping_method = shipping_method
          @warnings = warnings
          @data = data
        end
      end
    end
  end
end
