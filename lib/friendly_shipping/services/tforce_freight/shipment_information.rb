# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      class ShipmentInformation
        attr_reader :documents,
                    :bol_id,
                    :pro_number,
                    :origin_service_center,
                    :email_sent,
                    :origin_is_rural,
                    :destination_is_rural,
                    :rates,
                    :total_charges,
                    :billable_weight,
                    :days_in_transit,
                    :shipping_method,
                    :warnings,
                    :data

        def initialize(
          bol_id:,
          pro_number: nil,
          origin_service_center: nil,
          email_sent: nil,
          origin_is_rural: nil,
          destination_is_rural: nil,
          rates: [],
          total_charges: nil,
          billable_weight: nil,
          days_in_transit: nil,
          documents: [],
          shipping_method: nil,
          warnings: nil,
          data: {}
        )
          @bol_id = bol_id
          @pro_number = pro_number
          @origin_service_center = origin_service_center
          @email_sent = email_sent
          @origin_is_rural = origin_is_rural
          @destination_is_rural = destination_is_rural
          @rates = rates
          @total_charges = total_charges
          @billable_weight = billable_weight
          @days_in_transit = days_in_transit
          @documents = documents
          @shipping_method = shipping_method
          @warnings = warnings
          @data = data
        end
      end
    end
  end
end
