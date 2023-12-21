# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateHandlingUnitsHash
        class << self
          # @param [Physical::Shipment] shipment
          # @param [FriendlyShipping::ShipmentOptions] options
          # @return [Hash]
          def call(shipment:, options:)
            handling_units(shipment, options).reduce(&:merge)
          end

          private

          # @param [Physical::Shipment] shipment
          # @param [FriendlyShipping::ShipmentOptions] options
          # @return [Array<Hash>]
          def handling_units(shipment, options)
            all_package_options = shipment.packages.map { |package| options.options_for_package(package) }
            all_package_options.group_by(&:handling_unit_code).map do |_handling_unit_code, options_group|
              [options_group.first, options_group.length]
            end.map { |package_options, quantity| handling_unit_hash(package_options, quantity) }
          end

          # @param [FriendlyShipping::PackageOptions] package_options
          # @param [Integer] quantity
          # @return [Hash]
          def handling_unit_hash(package_options, quantity)
            {
              package_options.handling_unit_tag.to_sym => {
                Quantity: quantity.to_s,
                Type: {
                  Code: package_options.handling_unit_code,
                  Description: package_options.handling_unit_description
                }
              }
            }
          end
        end
      end
    end
  end
end
