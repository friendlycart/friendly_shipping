# frozen_string_literal: true

module FriendlyShipping
  class ShipmentOptions
    def initialize(
      package_options: Set.new,
      package_options_finder: method(:find_package_options),
      package_options_class: PackageOptions
    )
      @package_options = package_options
      @package_options_finder = package_options_finder
      @package_options_class = package_options_class
    end

    def options_for_package(package)
      @package_options_finder.call(package_options, package)
    end

    private

    def find_package_options(package_options, package)
      package_options.detect do |package_option|
        package_option.package_id == package.id
      end || package_options_class.new(package_id: nil)
    end

    attr_reader :package_options, :package_options_class
  end
end
