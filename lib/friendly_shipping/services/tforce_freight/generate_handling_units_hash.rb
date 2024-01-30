# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      class GenerateHandlingUnitsHash
        class << self
          # @param shipment [Physical::Shipment]
          # @param options [FriendlyShipping::ShipmentOptions]
          # @return [Hash]
          def call(shipment:, options:)
            handling_units(shipment, options).reduce(&:merge)
          end

          private

          # @param shipment [Physical::Shipment]
          # @param options [FriendlyShipping::ShipmentOptions]
          # @return [Array<Hash>]
          def handling_units(shipment, options)
            all_package_options = shipment.packages.map { |package| options.options_for_package(package) }
            all_package_options.group_by(&:handling_unit_code).map do |_handling_unit_code, options_group|
              [options_group.first, options_group.length]
            end.map { |package_options, quantity| handling_unit_hash(package_options, quantity) }
          end

          # @param package_options [FriendlyShipping::PackageOptions]
          # @param quantity [Integer]
          # @return [Hash]
          def handling_unit_hash(package_options, quantity)
            {
              package_options.handling_unit_tag.to_sym => {
                quantity: quantity,
                typeCode: package_options.handling_unit_code
              }
            }
          end
        end
      end
    end
  end
end
