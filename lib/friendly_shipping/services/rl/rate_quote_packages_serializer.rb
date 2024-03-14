# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Serializes packages for R+L rate quote API requests.
      class RateQuotePackagesSerializer
        class << self
          # @param packages [Array<Physical::Package>] packages to serialize
          # @param options [RateQuoteOptions] options for this request
          # @return [Array<Hash>] serialized packages
          def call(packages:, options:)
            item_hashes = packages.flat_map do |package|
              package_options = options.options_for_package(package)
              package.items.map do |item|
                item_options = package_options.options_for_item(item)
                {
                  Class: item_options.freight_class,
                  Height: item.height.convert_to(:inches),
                  Length: item.length.convert_to(:inches),
                  Weight: item.weight.convert_to(:pounds),
                  Width: item.width.convert_to(:inches)
                }
              end
            end
            group_items(item_hashes)
          end

          private

          # Group items by freight class. The R+L Carriers API has a limit on the number of items
          # we can submit to the API, so this helps reduce the number of items.
          #
          # @param item_hashes [Array<Hash>] the item hashes to group
          # @return [Array<Hash>] item hashes grouped by freight class
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
