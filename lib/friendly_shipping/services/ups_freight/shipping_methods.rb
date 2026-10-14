# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Countries a UPS Freight shipment can originate from.
      ORIGIN_COUNTRIES = %w(
        CA MX PR US
      ).map { |country_code| Carmen::Country.coded(country_code) }.freeze

      # The UPS Freight shipping methods, built from service codes and names.
      SHIPPING_METHODS = [
        ['308', 'UPS Freight LTL'],
        ['309', 'UPS Freight LTL - Guaranteed'],
        ['334', 'UPS Freight LTL - Guaranteed A.M.'],
        ['349', 'UPS Standard LTL']
      ].freeze.map do |code, name|
        FriendlyShipping::ShippingMethod.new(
          name: name,
          service_code: code,
          origin_countries: ORIGIN_COUNTRIES,
          multi_package: true
        ).freeze
      end
    end
  end
end
