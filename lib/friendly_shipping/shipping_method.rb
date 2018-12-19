module FriendlyShipping
  class ShippingMethod
    attr_reader :name, :service_code

    def initialize(name: nil, service_code: nil, domestic: nil, international: nil, multi_package: nil)
      @name = name
      @service_code = service_code
      @domestic = domestic
      @international = international
      @multi_package = multi_package
    end

    def domestic?
      !!domestic
    end

    def international?
      !!international?
    end

    def multi_package?
      !!multi_package
    end

    private

    attr_reader :domestic, :international, :multi_package
  end
end
