# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Generates a handling units hash for JSON serialization.
      class GenerateHandlingUnitsHash
        class << self
          # @param shipment [Physical::Shipment]
          # @param options [ShipmentOptions]
          # @return [Hash]
          def call(shipment:, options:)
            handling_units(shipment, options).reduce(&:merge)
          end

          private

          # @param shipment [Physical::Shipment]
          # @param options [ShipmentOptions]
          # @return [Array<Hash>]
          def handling_units(shipment, options)
            if shipment.packages.any?
              warn "[DEPRECATION] `packages` is deprecated.  Please use `structures` instead."
              all_package_options = shipment.packages.map { |package| options.options_for_package(package) }
              all_package_options.group_by(&:handling_unit_code).map do |_handling_unit_code, options_group|
                [options_group.first, options_group.length]
              end.map { |package_options, quantity| handling_unit_hash(package_options, quantity) }
            else
              all_structure_options = shipment.structures.map { |structure| options.options_for_structure(structure) }
              all_structure_options.group_by(&:handling_unit_code).map do |_handling_unit_code, options_group|
                [options_group.first, options_group.length]
              end.map { |structure_options, quantity| handling_unit_hash(structure_options, quantity) }
            end
          end

          # @param options [PackageOptions, StructureOptions]
          # @param quantity [Integer]
          # @return [Hash]
          def handling_unit_hash(options, quantity)
            {
              options.handling_unit_tag.to_sym => {
                Quantity: quantity.to_s,
                Type: {
                  Code: options.handling_unit_code,
                  Description: options.handling_unit_description
                }
              }
            }
          end
        end
      end
    end
  end
end
