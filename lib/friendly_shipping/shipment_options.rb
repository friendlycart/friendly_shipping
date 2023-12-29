# frozen_string_literal: true

module FriendlyShipping
  # Base class for shipment options. Used when serializing API requests.
  class ShipmentOptions
    # @param package_options [Array<PackageOptions>] the options for packages in this shipment
    # @param package_options_class [Class] the class to use for package options when none are provided
    def initialize(
      package_options: Set.new,
      package_options_class: PackageOptions
    )
      @package_options = package_options
      @package_options_class = package_options_class
    end

    # Finds and returns package options for the given item. If options cannot be
    # found, the `package_options_class` is used to construct new options.
    #
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
