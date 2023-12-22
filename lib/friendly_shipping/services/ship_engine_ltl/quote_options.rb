# frozen_string_literal: true

require 'friendly_shipping/shipment_options'

module FriendlyShipping
  module Services
    class ShipEngineLTL
      class QuoteOptions < ShipmentOptions
        attr_reader :service_code,
                    :pickup_date,
                    :accessorial_service_codes,
                    :packages_serializer_class

        # @param [String] service_code
        # @param [Time] pickup_date
        # @param [Array<String>] accessorial_service_codes
        # @param [Class] packages_serializer_class
        def initialize(
          service_code: nil,
          pickup_date: nil,
          accessorial_service_codes: [],
          packages_serializer_class: SerializePackages,
          **kwargs
        )
          @service_code = service_code
          @pickup_date = pickup_date
          @accessorial_service_codes = accessorial_service_codes
          @packages_serializer_class = packages_serializer_class
          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end
      end
    end
  end
end
