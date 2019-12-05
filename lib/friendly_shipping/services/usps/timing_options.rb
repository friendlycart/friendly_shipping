# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      class TimingOptions
        attr_reader :pickup, :shipping_method

        def initialize(
          pickup: Time.now,
          shipping_method: nil
        )
          @pickup = pickup
          @shipping_method = shipping_method
        end
      end
    end
  end
end
