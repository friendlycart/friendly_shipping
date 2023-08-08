# frozen_string_literal: true

require 'friendly_shipping/shipment_options'

module FriendlyShipping
  module Services
    class RL
      class BillOfLadingOptions < ShipmentOptions
        attr_reader :pickup_time_window,
                    :declared_value,
                    :additional_service_codes

        # @param [Range] pickup_time_window
        # @param [Array<String>] additional_service_codes
        # @param [Array<Object>] **kwargs
        def initialize(
          pickup_time_window:,
          declared_value: nil,
          additional_service_codes: [],
          **kwargs
        )
          @pickup_time_window = pickup_time_window
          @declared_value = declared_value
          @additional_service_codes = additional_service_codes
          validate_additional_service_codes!
          super(**kwargs.merge(package_options_class: PackageOptions))
        end

        ADDITIONAL_SERVICE_CODES = %w[
          OriginLiftgate
          DestinationLiftgate
          InsidePickup
          InsideDelivery
          LimitedAccessPickup
          LimitedAccessDelivery
          Freezable
          DeliveryAppointment
        ].freeze

        private

        # @raise [ArgumentError] invalid additional service codes
        # @return [nil]
        def validate_additional_service_codes!
          invalid_codes = (additional_service_codes - ADDITIONAL_SERVICE_CODES)
          return unless invalid_codes.any?

          raise ArgumentError, "Invalid additional service code(s): #{invalid_codes.join(',')}"
        end
      end
    end
  end
end
