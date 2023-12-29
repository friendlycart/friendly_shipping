# frozen_string_literal: true

module FriendlyShipping
  # Represents a shipping method (UPS Ground, USPS Priority, etc.) that belongs to a {Carrier}.
  class ShippingMethod
    # @return [String] the shipping method's name
    attr_reader :name

    # @return [String] the shipping method's service code
    attr_reader :service_code

    # @return [Carrier] this shipping method's carrier
    attr_reader :carrier

    # @return [Array<String>] countries this shipping method ships from
    attr_reader :origin_countries

    # @return [Hash] additional carrier-specific data for this shipping method
    attr_reader :data

    # @param name [String] the shipping method's name
    # @param service_code [String] the shipping method's service code
    # @param domestic [Boolean] whether this is a domestic shipping method
    # @param international [Boolean] whether this is an international shipping method
    # @param multi_package [Boolean] whether this is a multi-package shipping method
    # @param carrier [Carrier] this shipping method's carrier
    # @param origin_countries [Array] countries this shipping method ships from
    # @param data [Hash] additional carrier-specific data for this shipping method
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

    # Returns true if this is a domestic shipping method.
    # @return [Boolean]
    def domestic?
      !!domestic
    end

    # Returns true if this is an international shipping method.
    # @return [Boolean]
    def international?
      !!international
    end

    # Returns true if this shipping method supports multiple packages.
    # @return [Boolean]
    def multi_package?
      !!multi_package
    end

    private

    # @return [Boolean]
    attr_reader :domestic

    # @return [Boolean]
    attr_reader :international

    # @return [Boolean]
    attr_reader :multi_package
  end
end
