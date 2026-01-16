# frozen_string_literal: true

module FriendlyShipping
  module Services
    class G2Mint
      ORIGIN_COUNTRIES = %w(US)
        .map { |country_code| Carmen::Country.coded(country_code) }.freeze

      # G2Mint is a TMS/broker platform that returns rates from multiple carriers
      # with varying service levels. Shipping methods are created dynamically
      # based on the carriers and service levels returned in the rates response.
      SHIPPING_METHODS = [
        ["ltl", "LTL Freight"]
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
