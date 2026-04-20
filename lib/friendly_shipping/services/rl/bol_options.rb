# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Bill of Lading (BOL) options class. Used when serializing R+L API requests.
      class BOLOptions < ShipmentOptions
        # @return [Range] the pickup time window
        attr_reader :pickup_time_window

        # @return [String] the pickup instructions
        attr_reader :pickup_instructions

        # @return [Numeric] the declared value of this shipment
        attr_reader :declared_value

        # @return [String] any special instructions
        attr_reader :special_instructions

        # @return [Hash] reference numbers for the shipment
        attr_reader :reference_numbers

        # @return [Array<String>] additional service codes
        attr_reader :additional_service_codes

        # @return [Boolean] whether to generate universal PRO number
        attr_reader :generate_universal_pro

        # @return [Callable]
        # @deprecated Use {#handling_units_serializer} instead. Sending top-level
        #   `Items` will be removed in a future release in favor of `HandlingUnits`.
        attr_reader :structures_serializer

        # @return [Callable, nil] the handling units serializer. When set, the
        #   serialized request sends `HandlingUnits` in place of the top-level `Items`.
        #   This will become the default in a future release.
        attr_reader :handling_units_serializer

        # @return [Callable]
        # @deprecated Use {#handling_units_serializer} instead.
        attr_reader :packages_serializer

        # @param pickup_time_window [Range]
        # @param pickup_instructions [String]
        # @param declared_value [Numeric]
        # @param special_instructions [String]
        # @param reference_numbers [Hash]
        # @param additional_service_codes [Array<String>]
        # @param generate_universal_pro [Boolean]
        # @param structures_serializer [Callable] a callable that takes structures
        #   and an options object to create an Array of item hashes per the R+L Carriers docs
        #   (DEPRECATED: use `handling_units_serializer` instead)
        # @param handling_units_serializer [Callable, nil] a callable that takes structures
        #   and an options object to create an Array of HandlingUnit hashes per the R+L Carriers docs.
        #   When provided, the request sends `HandlingUnits` instead of the top-level `Items` array.
        #   This will become the default in a future release.
        # @param packages_serializer [Callable] a callable that takes packages
        #   and an options object to create an Array of item hashes per the R+L Carriers docs
        #   (DEPRECATED: use `handling_units_serializer` instead)
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
        def initialize(
          pickup_time_window:,
          pickup_instructions: nil,
          declared_value: nil,
          special_instructions: nil,
          reference_numbers: {},
          additional_service_codes: [],
          structures_serializer: BOLStructuresSerializer,
          handling_units_serializer: nil,
          packages_serializer: BOLPackagesSerializer,
          generate_universal_pro: false,
          **kwargs
        )
          @pickup_time_window = pickup_time_window
          @pickup_instructions = pickup_instructions
          @declared_value = declared_value
          @special_instructions = special_instructions
          @reference_numbers = reference_numbers
          @additional_service_codes = additional_service_codes
          @structures_serializer = structures_serializer
          @handling_units_serializer = handling_units_serializer
          @packages_serializer = packages_serializer
          @generate_universal_pro = generate_universal_pro
          validate_additional_service_codes!
          super(**kwargs)
        end

        # Optional service codes that can be used for R+L shipments.
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
