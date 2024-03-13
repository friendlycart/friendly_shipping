# frozen_string_literal: true

require 'friendly_shipping/shipment_options'

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for generating rates for a shipment
      #
      # @attribute carriers [Array<FriendlyShipping::Carrier>] a list of the carriers we want to get IDs from.
      # @attribute service_code [String] The service code we want to get rates for.
      # @attribute ship_date [#strftime] The date we want to ship on.
      # @attribute comparison_rate_type [String] Set to "retail" for retail rates (UPS/USPS only).
      class RatesOptions < FriendlyShipping::ShipmentOptions
        attr_reader :carriers,
                    :service_code,
                    :ship_date,
                    :comparison_rate_type

        def initialize(
          carriers:,
          service_code:,
          ship_date: Date.today,
          comparison_rate_type: nil,
          **kwargs
        )
          @carriers = carriers
          @service_code = service_code
          @ship_date = ship_date
          @comparison_rate_type = comparison_rate_type
          validate_comparison_rate_type!
          super(**kwargs.reverse_merge(package_options_class: RatesPackageOptions))
        end

        def carrier_ids
          carriers.map(&:id)
        end

        private

        def validate_comparison_rate_type!
          return if comparison_rate_type.nil? || comparison_rate_type == "retail"

          raise ArgumentError, "Invalid comparison rate type: #{comparison_rate_type}"
        end
      end
    end
  end
end
