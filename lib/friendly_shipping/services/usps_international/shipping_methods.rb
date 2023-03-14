# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UspsInternational
      SHIPPING_METHODS = [
        ["1", "Priority Mail Express International"],
        ["2", "Priority Mail International"],
        ["4", "Global Express Guaranteed; (GXG)"],
        ["5", "Global Express Guaranteed; Document"],
        ["6", "Global Express Guarantee; Non-Document Rectangular"],
        ["7", "Global Express Guaranteed; Non-Document Non-Rectangular"],
        ["8", "Priority Mail International; Flat Rate Envelope"],
        ["9", "Priority Mail International; Medium Flat Rate Box"],
        ["10", "Priority Mail Express International; Flat Rate Envelope"],
        ["11", "Priority Mail International; Large Flat Rate Box"],
        ["12", "USPS GXG; Envelopes"],
        ["13", "First-Class Mail; International Letter"],
        ["14", "First-Class Mail; International Large Envelope"],
        ["15", "First-Class Package International Service"],
        ["16", "Priority Mail International; Small Flat Rate Box"],
        ["17", "Priority Mail Express International; Legal Flat Rate Envelope"],
        ["18", "Priority Mail International; Gift Card Flat Rate Envelope"],
        ["19", "Priority Mail International; Window Flat Rate Envelope"],
        ["20", "Priority Mail International; Small Flat Rate Envelope"],
        ["28", "Airmail M-Bag"]
      ].map do |code, name|
        FriendlyShipping::ShippingMethod.new(
          origin_countries: [Carmen::Country.coded('US')],
          name: name,
          service_code: code,
          domestic: false,
          international: true,
        )
      end.freeze
    end
  end
end
