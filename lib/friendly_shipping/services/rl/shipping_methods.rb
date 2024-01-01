# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      # Available origin countries for R+L shipments.
      ORIGIN_COUNTRIES = %w[
        AG BB CA DO GU GY JM PR VC TT US VG VI
      ].map { |country_code| Carmen::Country.coded(country_code) }.freeze

      # Available R+L shipping methods.
      SHIPPING_METHODS = [
        ["STD", "Standard Service"],
        ["GSDS", "Guaranteed Service"],
        ["GSAM", "Guaranteed AM Service"],
        ["GSHW", "Guaranteed Hourly Window Service"],
        ["EXPD", "Expedited Service"]
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
