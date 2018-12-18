module FriendlyShipping
  class Carrier
    attr_reader :id, :name, :services, :balance

    def initialize(id: nil, name: nil, services: [], balance: nil, auth: {})
      @id = id
      @name = name
      @services = services
      @balance = balance
    end
  end
end
