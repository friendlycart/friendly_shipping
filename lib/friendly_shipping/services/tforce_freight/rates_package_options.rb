# frozen_string_literal: true

require 'friendly_shipping/services/tforce_freight/package_options'

module FriendlyShipping
  module Services
    class TForceFreight
      # @deprecated use {FriendlyShipping::Services::TForceFreight::PackageOptions} instead
      RatesPackageOptions = PackageOptions
    end
  end
end
