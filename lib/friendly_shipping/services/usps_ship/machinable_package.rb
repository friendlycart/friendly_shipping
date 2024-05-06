# frozen_string_literal: true

module FriendlyShipping
  module Services
    class USPSShip
      # USPS has certain size and weight requirements for packages to be considered
      # machinable. Machinable packages are generally less expensive to ship.
      # @see https://pe.usps.com/BusinessMail101?ViewName=Parcels
      #
      class MachinablePackage
        # @return [Physical::Package]
        attr_reader :package

        MIN_LENGTH = Measured::Length(6, :inches)
        MIN_WIDTH = Measured::Length(3, :inches)
        MIN_HEIGHT = Measured::Length(0.25, :inches)

        MAX_LENGTH = Measured::Length(22, :inches)
        MAX_WIDTH = Measured::Length(18, :inches)
        MAX_HEIGHT = Measured::Length(15, :inches)

        MIN_WEIGHT = Measured::Weight(6, :ounces)
        MAX_WEIGHT = Measured::Weight(25, :pounds)

        # @param package [Physical::Package]
        def initialize(package)
          @package = package
        end

        # @return [Boolean]
        def machinable?
          at_least_minimum && at_most_maximum
        end

        private

        # @return [Boolean]
        def at_least_minimum
          package.length >= MIN_LENGTH &&
            package.width >= MIN_WIDTH &&
            package.height >= MIN_HEIGHT &&
            package.weight >= MIN_WEIGHT
        end

        # @return [Boolean]
        def at_most_maximum
          package.length <= MAX_LENGTH &&
            package.width <= MAX_WIDTH &&
            package.height <= MAX_HEIGHT &&
            package.weight <= MAX_WEIGHT
        end
      end
    end
  end
end
