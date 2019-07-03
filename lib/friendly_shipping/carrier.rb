# frozen_string_literal: true

module FriendlyShipping
  class Carrier
    attr_reader :id, :name, :code, :shipping_methods, :balance, :data

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
