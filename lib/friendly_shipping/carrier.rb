# frozen_string_literal: true

module FriendlyShipping
  class Carrier
    attr_reader :id, :name, :code, :shipping_methods, :balance, :data

    # @param [Integer] id The carrier's ID
    # @param [String] name The carrier's name
    # @param [String] code The carrier's unique code
    # @param [Array] shipping_methods The shipping methods available on this carrier
    # @param [Float] balance The remaining balance for this carrier
    # @param [Hash] data Additional data related to this carrier
    def initialize(id: nil, name: nil, code: nil, shipping_methods: [], balance: nil, data: {})
      @id = id
      @name = name
      @code = code
      @shipping_methods = shipping_methods
      @balance = balance
      @data = data
    end

    def ==(other)
      id == other.id
    end
  end
end
