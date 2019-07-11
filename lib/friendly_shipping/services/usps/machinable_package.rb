# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      # USPS has certain size and weight requirements for packages to
      # be considered machinable. Machinable packages are generally
      # less expensive to ship. For more information see:
      #   https://pe.usps.com/BusinessMail101?ViewName=Parcels
      #
      class MachinablePackage
        attr_reader :package

        MIN_LENGTH = Measured::Length(6, :inches)
        MIN_WIDTH = Measured::Length(3, :inches)
        MIN_HEIGHT = Measured::Length(0.25, :inches)

        MAX_LENGTH = Measured::Length(27, :inches)
        MAX_WIDTH = Measured::Length(17, :inches)
        MAX_HEIGHT = Measured::Length(17, :inches)
        MAX_WEIGHT = Measured::Weight(25, :pounds)

        # @param [Physical::Package]
        def initialize(package)
          @package = package
        end

        def machinable?
          at_least_minimum && at_most_maximum
        end

        private

        def at_least_minimum
          package.length >= MIN_LENGTH &&
            package.width >= MIN_WIDTH &&
            package.height >= MIN_HEIGHT
        end

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
