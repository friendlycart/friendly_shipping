# frozen_string_literal: true

require 'friendly_shipping/services/rl/shipment_options'
require 'friendly_shipping/services/rl/rate_quote_structures_serializer'
require 'friendly_shipping/services/rl/rate_quote_packages_serializer'

module FriendlyShipping
  module Services
    class RL
      # Rate quote options for serializing R+L API requests.
      class RateQuoteOptions < ShipmentOptions
        # @return [Time] the pickup date
        attr_reader :pickup_date

        # @return [Numeric] the declared value of this shipment
        attr_reader :declared_value

        # @return [Array<String>] additional service codes
        attr_reader :additional_service_codes

        # @return [Callable] the serializer for this shipment's structures
        attr_reader :structures_serializer

        # @return [Callable] the serializer for this shipment's packages
        # @deprecated Use {#structures_serializer} instead.
        attr_reader :packages_serializer

        # @param pickup_date [Time] the pickup date
        # @param declared_value [Numeric] the declared value of this shipment
        # @param additional_service_codes [Array<String>] additional service codes
        # @param structures_serializer [Callable] a callable that takes structures
        #   and an options object to create an Array of item hashes per the R+L Carriers docs
        # @param packages_serializer [Callable] a callable that takes packages
        #   and an options object to create an Array of item hashes per the R+L Carriers docs (DEPRECATED: use ``structures_serializer`` instead)
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
        def initialize(
          pickup_date:,
          declared_value: nil,
          additional_service_codes: [],
          structures_serializer: RateQuoteStructuresSerializer,
          packages_serializer: RateQuotePackagesSerializer,
          **kwargs
        )
          @pickup_date = pickup_date
          @declared_value = declared_value
          @additional_service_codes = additional_service_codes
          @structures_serializer = structures_serializer
          @packages_serializer = packages_serializer
          validate_additional_service_codes!
          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end

        # Optional service codes that can be used for R+L shipments.
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

        # Raises an exception if the additional service codes passed into the initializer
        # don't correspond to valid codes from {ADDITIONAL_SERVICE_CODES}.
        #
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
