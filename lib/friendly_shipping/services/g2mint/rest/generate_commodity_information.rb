# frozen_string_literal: true

module FriendlyShipping
  module Services
    class G2Mint
      module REST
        # Generates commodity information for G2Mint API requests.
        # Structures contain packages; each package becomes a commodity entry.
        class GenerateCommodityInformation
          class << self
            # @param shipment [Physical::Shipment] the shipment with structures
            # @param options [RatesOptions] options for this request
            # @return [Array<Hash>] commodities for G2Mint API
            def call(shipment:, options:)
              shipment.structures.flat_map do |structure|
                structure_options = options.options_for_structure(structure)

                structure.packages.map do |package|
                  package_options = structure_options.options_for_package(package)

                  {
                    handlingUnitId: structure.id,
                    # packageType: package_options.packaging_unit_type, old/legacy
                    packageUnitId: package.id,
                    productCode: package_options.product_code,
                    isHazmat: package_options.is_hazmat,
                    freightClass: package_options.freight_class,
                    nmfc: package_options.nmfc,  # no validation
                    weight: package.weight.convert_to(:lbs).value.to_f.round, # total weight
                    units: 1
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
