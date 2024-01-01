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

        # The minimum length of a machinable package
        MIN_LENGTH = Measured::Length(6, :inches)
        # The minimum width of a machinable package
        MIN_WIDTH = Measured::Length(3, :inches)
        # The minimum height of a machinable package
        MIN_HEIGHT = Measured::Length(0.25, :inches)

        # The maximum length of a machinable package
        MAX_LENGTH = Measured::Length(22, :inches)
        # The maximum width of a machinable package
        MAX_WIDTH = Measured::Length(18, :inches)
        # The maximum height of a machinable package
        MAX_HEIGHT = Measured::Length(15, :inches)

        # The minimum weight of a machinable package
        MIN_WEIGHT = Measured::Weight(6, :ounces)
        # The maximum weight of a machinable package
        MAX_WEIGHT = Measured::Weight(25, :pounds)

        # @param package [Physical::Package]
        def initialize(package)
          @package = package
        end

        # @return [Boolean]
        def machinable?
          at_least_minimum? && at_most_maximum?
        end

        private

        # @return [Boolean]
        def at_least_minimum?
          package.length >= MIN_LENGTH &&
            package.width >= MIN_WIDTH &&
            package.height >= MIN_HEIGHT &&
            package.weight >= MIN_WEIGHT
        end

        # @return [Boolean]
        def at_most_maximum?
          package.length <= MAX_LENGTH &&
            package.width <= MAX_WIDTH &&
            package.height <= MAX_HEIGHT &&
            package.weight <= MAX_WEIGHT
        end
      end
    end
  end
end
