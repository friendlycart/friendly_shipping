# frozen_string_literal: true

module FriendlyShipping
  module Services
    class G2Mint
      module REST
        # Generates packaging units for G2Mint API requests.
        # A packaging unit represents the box or container for each package.
        class GeneratePackagingUnits
          class << self
            # @param shipment [Physical::Shipment] the shipment with structures
            # @param options [RatesOptions] options for this request
            # @return [Array<Hash>] packaging units for G2Mint API
            def call(shipment:, options:)
              shipment.structures.flat_map do |structure|
                structure_options = options.options_for_structure(structure)

                structure.packages.map do |package|
                  package_options = structure_options.options_for_package(package)

                  {
                    id: package.id,
                    puConfigCode: package_options.packaging_config_code,
                    quantity: 1,
                    unitType: package_options.packaging_unit_type,
                    weight: package.weight.convert_to(:lbs).value.to_f.round,
                    length: package.length.convert_to(:in).value.to_f.round,
                    width: package.width.convert_to(:in).value.to_f.round,
                    height: package.height.convert_to(:in).value.to_f.round
                  }.compact
                end
              end
            end
          end
        end
      end
    end
  end
end
