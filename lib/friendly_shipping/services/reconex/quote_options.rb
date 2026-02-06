# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Options for a Reconex quote request.
      class QuoteOptions < FriendlyShipping::ShipmentOptions
        # @return [Time, nil] the must-arrive-by date (ISO 8601)
        attr_reader :must_arrive_by_date

        # @return [String] the origin/destination dock type
        attr_reader :dock_type

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
        def initialize(
          must_arrive_by_date: nil,
          dock_type: "BusinessWithDock",
          total_quantity: "1",
          total_units: "Pallets",
          accessorials: {},
          structure_options: [],
          structure_options_class: StructureOptions,
          **kwargs
        )
          @must_arrive_by_date = must_arrive_by_date
          @dock_type = dock_type
          @total_quantity = total_quantity
          @total_units = total_units
          @accessorials = accessorials
          @structure_options = structure_options
          @structure_options_class = structure_options_class
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
      end
    end
  end
end
