# frozen_string_literal: true

require 'friendly_shipping/shipment_options'
require 'friendly_shipping/services/rl/rate_quote_packages_serializer'

module FriendlyShipping
  module Services
    class RL
      class RateQuoteOptions < ShipmentOptions
        attr_reader :pickup_date,
                    :declared_value,
                    :additional_service_codes,
                    :packages_serializer

        # @param [Time] pickup_date
        # @param [Numeric] declared_value
        # @param [Array<String>] additional_service_codes
        # @param [Callable] packages_serializer A callable that takes packages
        #   and an options object to create an Array of item hashes per the R+L Carriers docs
        # @param [Array<Object>] **kwargs
        def initialize(
          pickup_date:,
          declared_value: nil,
          additional_service_codes: [],
          packages_serializer: RateQuotePackagesSerializer,
          **kwargs
        )
          @pickup_date = pickup_date
          @declared_value = declared_value
          @additional_service_codes = additional_service_codes
          @packages_serializer = packages_serializer
          validate_additional_service_codes!
          super(**kwargs.merge(package_options_class: PackageOptions))
        end

        ADDITIONAL_SERVICE_CODES = %w[
          InsideDelivery
          LimitedAccessPickup
          LimitedAccessDelivery
          OriginLiftgate
          DestinationLiftgate
          DeliveryAppointment
          Hazmat
          InsidePickup
          Freezable
          SortAndSegregate
          OverDimension
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
