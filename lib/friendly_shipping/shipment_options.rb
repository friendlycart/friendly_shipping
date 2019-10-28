# frozen_string_literal: true

module FriendlyShipping
  class ShipmentOptions
    def initialize(
      package_options: Set.new,
      package_options_finder: method(:find_package_options)
    )
      @package_options = package_options
      @package_options_finder = package_options_finder
    end

    def options_for_package(package)
      @package_options_finder.call(package_options, package)
    end

    private

    def find_package_options(package_options, package)
      package_options.detect { |package_option| package_option.package_id == package.id }
    end

    attr_reader :package_options
  end
end
