# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Options for a Reconex quote request.
      class QuoteOptions < FriendlyShipping::ShipmentOptions
        # Valid dock types for origin and destination locations.
        DOCK_TYPES = %w[
          BusinessWithDock BusinessWithOutDock Residence OtherLimitedAccess
          Construction Church Military StorageFacility School Farm Mine
          Prison Government Nuclear Hotel GroceryWarehouse
        ].freeze

        # Valid accessorial service keys (snake_case, serialized to camelCase).
        ACCESSORIALS = %w[
          do_not_freeze over_length sort_and_segregate blind_shipment
          white_glove_delivery expedite insurance_required falvey_ins_value
          volume_load guaranteed mabd destination_notification
          origin_inside_pickup origin_liftgate destination_inside_delivery
          destination_liftgate in_bond
        ].map(&:to_sym).freeze

        # @return [Time, nil] the must-arrive-by date (ISO 8601)
        attr_reader :must_arrive_by_date

        # @return [String] the origin dock type
        attr_reader :dock_type

        # @return [String] the destination dock type
        attr_reader :destination_dock_type

        # @return [String] the total quantity (e.g. "1")
        attr_reader :total_quantity

        # @return [String] the total units (e.g. "Pallets")
        attr_reader :total_units

        # @return [Hash] boolean flags for accessorial services
        attr_reader :accessorials

        # @param must_arrive_by_date [Time, nil] the must-arrive-by date
        # @param dock_type [String] the dock type (default: "BusinessWithDock")
        # @param total_quantity [String] the total quantity
        # @param total_units [String] the total units
        # @param accessorials [Hash] boolean flags for accessorial services
        # @param structure_options [Array<StructureOptions>] the options for structures
        # @param structure_options_class [Class] the class for structure options
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages
        # @option kwargs [Class] :package_options_class the class for package options
        # @param destination_dock_type [String] the destination dock type (defaults to dock_type)
        def initialize(
          must_arrive_by_date: nil,
          dock_type: "BusinessWithDock",
          destination_dock_type: nil,
          total_quantity: "1",
          total_units: "Pallets",
          accessorials: {},
          structure_options: [],
          structure_options_class: StructureOptions,
          **kwargs
        )
          @must_arrive_by_date = must_arrive_by_date
          @dock_type = dock_type
          @destination_dock_type = destination_dock_type || dock_type
          @total_quantity = total_quantity
          @total_units = total_units
          @accessorials = accessorials
          @structure_options = structure_options
          @structure_options_class = structure_options_class
          validate_dock_type!
          validate_total_units!
          validate_accessorials!
          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end

        # @param structure [#id] the structure for which to get options
        # @return [StructureOptions]
        def options_for_structure(structure)
          structure_options.detect do |structure_option|
            structure_option.structure_id == structure.id
          end || structure_options_class.new(structure_id: nil)
        end

        private

        # @return [Array<StructureOptions>]
        attr_reader :structure_options

        # @return [Class]
        attr_reader :structure_options_class

        # @raise [ArgumentError] invalid dock type
        def validate_dock_type!
          [dock_type, destination_dock_type].each do |type|
            raise ArgumentError, "Invalid dock type: #{type}" unless DOCK_TYPES.include?(type)
          end
        end

        # @raise [ArgumentError] invalid total units
        def validate_total_units!
          return if PackageOptions::PACKAGING_TYPES.include?(total_units)

          raise ArgumentError, "Invalid total units: #{total_units}"
        end

        # @raise [ArgumentError] invalid accessorial keys
        def validate_accessorials!
          invalid_keys = accessorials.keys.map(&:to_sym) - ACCESSORIALS
          return if invalid_keys.empty?

          raise ArgumentError, "Invalid accessorial(s): #{invalid_keys.join(', ')}"
        end
      end
    end
  end
end
