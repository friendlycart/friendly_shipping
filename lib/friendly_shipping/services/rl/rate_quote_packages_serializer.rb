# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class RateQuotePackagesSerializer
        class << self
          # @param [Array<Physical::Package>] packages
          # @param [FriendlyShipping::Services::RL::RateQuoteOptions] options
          # @return [Array<Hash>]
          def call(packages:, options:)
            item_hashes = packages.flat_map do |package|
              package_options = options.options_for_package(package)
              package.items.map do |item|
                item_options = package_options.options_for_item(item)
                {
                  Class: item_options.freight_class,
                  Weight: item.weight.convert_to(:pounds)
                }
              end
            end
            group_items(item_hashes)
          end

          private

          # Group items by freight class. The R&L API has a limit on the number of items
          # we can submit to the API, so this helps reduce the number of items.
          #
          # @param [Array<Hash>] item_hashes
          # @return [Array<Hash>]
          def group_items(item_hashes)
            item_hashes.group_by do |item_hash|
              item_hash[:Class]
            end.map do |freight_class, grouped_item_hashes|
              {
                Class: freight_class,
                Weight: grouped_item_hashes.sum { |e| e[:Weight] }.value.ceil,
                Quantity: grouped_item_hashes.size
              }
            end
          end
        end
      end
    end
  end
end
