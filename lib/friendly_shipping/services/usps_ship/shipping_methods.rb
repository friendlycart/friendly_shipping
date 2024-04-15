# frozen_string_literal: true

module FriendlyShipping
  module Services
    class USPSShip
      SHIPPING_METHODS = [
        ["BOUND_PRINTED_MATTER", "Bound Printed Matter"],
        ["FIRST-CLASS_PACKAGE_RETURN_SERVICE", "First-Class Package Return Service"],
        ["FIRST-CLASS_PACKAGE_SERVICE", "First-Class Package Service"],
        ["GROUND_RETURN_SERVICE", "Ground Return Service"],
        ["LIBRARY_MAIL", "Library Mail"],
        ["MEDIA_MAIL", "Media Mail"],
        ["PARCEL_SELECT", "Parcel Select"],
        ["PARCEL_SELECT_LIGHTWEIGHT", "Parcel Select Lightweight"],
        ["PRIORITY_MAIL", "Priority Mail"],
        ["PRIORITY_MAIL_EXPRESS", "Priority Mail Express"],
        ["PRIORITY_MAIL_EXPRESS_RETURN_SERVICE", "Priority Mail Express Return Service"],
        ["PRIORITY_MAIL_RETURN_SERVICE", "Priority Mail Return Service"],
        ["USPS_CONNECT_LOCAL", "USPS Connect Local"],
        ["USPS_CONNECT_MAIL", "USPS Connect Mail"],
        ["USPS_CONNECT_NEXT_DAY", "USPS Connect Next Day"],
        ["USPS_CONNECT_REGIONAL", "USPS Connect Regional"],
        ["USPS_CONNECT_SAME_DAY", "USPS Connect Same Day"],
        ["USPS_GROUND_ADVANTAGE", "USPS Ground Advantage"],
        ["USPS_GROUND_ADVANTAGE_RETURN_SERVICE", "USPS Ground Advantage Return Service"],
        ["USPS_RETAIL_GROUND", "USPS Retail Ground"]
      ].map do |code, name|
        FriendlyShipping::ShippingMethod.new(
          origin_countries: [Carmen::Country.coded("US")],
          name: name,
          service_code: code,
          domestic: true,
          international: false
        )
      end.freeze
    end
  end
end
