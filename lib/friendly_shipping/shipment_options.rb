# frozen_string_literal: true

module FriendlyShipping
  class ShipmentOptions
    def initialize(
      package_options: Set.new,
      package_options_class: PackageOptions
    )
      @package_options = package_options
      @package_options_class = package_options_class
    end

    def options_for_package(package)
      package_options.detect do |package_option|
        package_option.package_id == package.id
      end || package_options_class.new(package_id: nil)
    end

    private

    attr_reader :package_options, :package_options_class
  end
end
