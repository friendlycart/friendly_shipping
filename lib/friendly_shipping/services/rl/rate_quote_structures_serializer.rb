# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class RateQuoteStructuresSerializer
        class << self
          # @param structures [Array<Physical::Structure>]
          # @param options [RateQuoteOptions]
          # @return [Array<Hash>]
          def call(structures:, options:)
            item_hashes = structures.flat_map do |structure|
              structure_options = options.options_for_structure(structure)
              structure.packages.map do |package|
                package_options = structure_options.options_for_package(package)
                {
                  Class: package_options.freight_class,
                  Height: package.height.convert_to(:inches),
                  Length: package.length.convert_to(:inches),
                  Weight: package.weight.convert_to(:pounds),
                  Width: package.width.convert_to(:inches)
                }
              end
            end
            group_items(item_hashes)
          end

          private

          # Group items by freight class. The R+L Carriers API has a limit on the number of items
          # we can submit to the API, so this helps reduce the number of items.
          #
          # @param item_hashes [Array<Hash>]
          # @return [Array<Hash>]
          def group_items(item_hashes)
            item_hashes.group_by do |item_hash|
              item_hash[:Class]
            end.map do |freight_class, grouped_item_hashes|
              {
                Class: freight_class,
                Height: grouped_item_hashes.map { _1[:Height].value.ceil }.max,
                Length: grouped_item_hashes.map { _1[:Length].value.ceil }.max,
                Weight: grouped_item_hashes.sum { _1[:Weight] }.value.ceil,
                Width: grouped_item_hashes.map { _1[:Width].value.ceil }.max,
                Quantity: grouped_item_hashes.size
              }
            end
          end
        end
      end
    end
  end
end
