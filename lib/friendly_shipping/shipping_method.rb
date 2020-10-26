# frozen_string_literal: true

module FriendlyShipping
  class ShippingMethod
    attr_reader :name, :service_code, :carrier, :origin_countries, :data

    # @param [String] name The shipping method's name
    # @param [String] service_code The shipping method's service code
    # @param [Boolean] domestic Whether this is a domestic shipping method
    # @param [Boolean] international Whether this is an international shipping method
    # @param [Boolean] multi_package Whether this is a multi-package shipping method
    # @param [FriendlyShipping::Carrier] carrier This shipping method's carrier
    # @param [Array] origin_countries Countries this shipping method ships from
    # @param [Hash] data Additional carrier-specific data for this shipping method
    def initialize(
      name: nil,
      service_code: nil,
      domestic: nil,
      international: nil,
      multi_package: nil,
      carrier: nil,
      origin_countries: [],
      data: {}
    )
      @name = name
      @service_code = service_code
      @domestic = domestic
      @international = international
      @multi_package = multi_package
      @carrier = carrier
      @origin_countries = origin_countries
      @data = data
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
