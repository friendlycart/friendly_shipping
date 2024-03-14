# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Serializes packages for R+L BOL API requests.
      class BOLPackagesSerializer
        # @param packages [Array<Physical::Package>] packages to serialize
        # @param options [BOLOptions] options for these packages
        # @return [Array<Hash>] serialized packages
        def self.call(packages:, options:)
          packages.flat_map do |package|
            package_options = options.options_for_package(package)
            package.items.map do |item|
              item_options = package_options.options_for_item(item)
              {
                IsHazmat: false,
                Pieces: 1,
                PackageType: "BOX",
                NMFCItemNumber: item_options.nmfc_primary_code,
                NMFCSubNumber: item_options.nmfc_sub_code,
                Class: item_options.freight_class,
                Weight: item.weight.convert_to(:pounds).value.ceil,
                Description: item.description.presence || "Commodities"
              }.compact
            end
          end
        end
      end
    end
  end
end
