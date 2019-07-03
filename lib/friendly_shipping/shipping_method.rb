# frozen_string_literal: true

module FriendlyShipping
  class ShippingMethod
    attr_reader :name, :service_code, :carrier, :origin_countries

    def initialize(
      name: nil,
      service_code: nil,
      domestic: nil,
      international: nil,
      multi_package: nil,
      carrier: nil,
      origin_countries: []
    )
      @name = name
      @service_code = service_code
      @domestic = domestic
      @international = international
      @multi_package = multi_package
      @carrier = carrier
      @origin_countries = origin_countries
    end

    def domestic?
      !!domestic
    end

    def international?
      !!international
    end

    def multi_package?
      !!multi_package
    end

    private

    attr_reader :domestic, :international, :multi_package
  end
end
