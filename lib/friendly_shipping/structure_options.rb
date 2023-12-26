# frozen_string_literal: true

module FriendlyShipping
  # Options for structures (pallets, skids, etc) in a shipment.
  class StructureOptions
    # @return [Object] unique identifier for this set of options
    attr_reader :structure_id

    # @param structure_id [Object] unique identifier for this set of options
    # @param package_options [Array<PackageOptions>] the options for packages in this structure
    # @param package_options_class [Class] the class to use for package options when none are provided
    def initialize(
      structure_id:,
      package_options: [],
      package_options_class: PackageOptions
    )
      @structure_id = structure_id
      @package_options = package_options
      @package_options_class = package_options_class
    end

    # @param package [#id] the package for which to get options
    # @return [PackageOptions]
    def options_for_package(package)
      package_options.detect do |package_option|
        package_option.package_id == package.id
      end || package_options_class.new(package_id: nil)
    end

    private

    # @return [Array<PackageOptions>]
    attr_reader :package_options

    # @return [Class]
    attr_reader :package_options_class
  end
end
