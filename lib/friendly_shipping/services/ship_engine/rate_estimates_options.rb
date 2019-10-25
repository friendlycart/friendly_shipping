# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      class RateEstimatesOptions
        attr_reader :carriers

        def initialize(carriers: [])
          @carriers = carriers
        end
      end
    end
  end
end
