# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngineLTL
      # Options for rate quote requests.
      class QuoteOptions < ShipmentOptions
        # @return [String] the service code to use when getting rates
        attr_reader :service_code

        # @return [Time] the pickup date
        attr_reader :pickup_date

        # @return [Array<String>] the accessorial service codes
        attr_reader :accessorial_service_codes

        # @return [Class] the class to use for serializing structures
        attr_reader :structures_serializer_class

        # @param service_code [String] the service code to use when getting rates
        # @param pickup_date [Time] the pickup date
        # @param accessorial_service_codes [Array<String>] the accessorial service codes (if any)
        # @param packages_serializer_class [Class] the class to use for serializing packages (DEPRECATED: use `structures_serializer_class` instead)
        # @param structures_serializer_class [Class] the class to use for serializing structures
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment (DEPRECATED: use `structure_options` instead)
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided (DEPRECATED: use `structure_options_class` instead)
        # @option kwargs [Array<StructureOptions>] :structure_options the options for structures in this shipment
        # @option kwargs [Class] :structure_options_class the class to use for structure options when none are provided
        def initialize(
          service_code: nil,
          pickup_date: nil,
          accessorial_service_codes: [],
          structures_serializer_class: SerializeStructures,
          packages_serializer_class: SerializePackages,
          **kwargs
        )
          @service_code = service_code
          @pickup_date = pickup_date
          @accessorial_service_codes = accessorial_service_codes
          @structures_serializer_class = structures_serializer_class
          @packages_serializer_class = packages_serializer_class
          super(**kwargs)
        end

        # @return [Class]
        # @deprecated Use {#structures_serializer_class} instead.
        def packages_serializer_class
          warn "[DEPRECATION] `packages_serializer_class` is deprecated.  Please use `structures_serializer_class` instead."
          @packages_serializer_class
        end
      end
    end
  end
end
