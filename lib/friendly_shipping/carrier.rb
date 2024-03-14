# frozen_string_literal: true

module FriendlyShipping
  # Represents a carrier (UPS, FedEx, etc.) and its {ShippingMethod} objects.
  class Carrier
    # @return [String] a unique identifier for this carrier
    attr_reader :id

    # @return [String] the carrier's name
    attr_reader :name

    # @return [String] the carrier's unique code
    attr_reader :code

    # @return [Array<ShippingMethod>] the shipping methods available on this carrier
    attr_reader :shipping_methods

    # @return [Float] the remaining balance for this carrier
    attr_reader :balance

    # @return [Hash] additional data related to this carrier
    attr_reader :data

    # @param id [Integer, String] a unique identifier for this carrier
    # @param name [String] the carrier's name
    # @param code [String] the carrier's unique code
    # @param shipping_methods [Array<ShippingMethod>] the shipping methods available on this carrier
    # @param balance [Float] the remaining balance for this carrier
    # @param data [Hash] additional data related to this carrier
    def initialize(id: nil, name: nil, code: nil, shipping_methods: [], balance: nil, data: {})
      @id = id
      @name = name
      @code = code
      @shipping_methods = shipping_methods
      @balance = balance
      @data = data
    end

    # Returns true if the given object shares the same ID with this carrier.
    # @param [Object] other
    # @return [Boolean]
    def ==(other)
      id == other.id
    end
  end
end
