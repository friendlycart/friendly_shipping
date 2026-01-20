# frozen_string_literal: true

module FriendlyShipping
  module Services
    class G2Mint
      module REST
        # Generates handling units (pallets) for G2Mint API requests.
        # Structures correspond to handling units. Each structure contains packages
        # and has dimensions and a total weight equal to the sum of its packages.
        class GenerateHandlingUnits
          class << self
            # @param shipment [Physical::Shipment] the shipment with structures
            # @param options [RatesOptions] options for this request
            # @return [Array<Hash>] handling units for G2Mint API
            def call(shipment:, options:)
              shipment.structures.map do |structure|
                structure_options = options.options_for_structure(structure)
                {
                  id: structure.id,
                  huConfigCode: structure_options.handling_unit_config_code,
                  units: 1,
                  unitType: structure_options.handling_unit_type,
                  weight: structure.packages_weight.convert_to(:lbs).value.to_f.round,
                  length: structure.length.convert_to(:in).value.to_f.round,
                  width: structure.width.convert_to(:in).value.to_f.round,
                  height: structure.height.convert_to(:in).value.to_f.round
                }.compact
              end
            end
          end
        end
      end
    end
  end
end
