# frozen_string_literal: true

require 'friendly_shipping/package_options'

module FriendlyShipping
  module Services
    class ShipEngine
      # Options relating to packages in the ShipEngine labels call
      #
      # @attribute :package_code [Symbol] The type of package. Possible types can be gotten
      #    via the ShipEngine API: https://www.shipengine.com/docs/reference/list-carrier-packages/
      #    If a package type is given, no dimensions will be added to the call (as we can assume the
      #    carrier knows the dimensions of their packaging types).
      # @attribute messages [Array<String>] A list of messages to add to the label. No carrier accepts
      #    more than three messages, and some have restrictions on how many characters are possible.
      #    We're not validating here though.
      class LabelPackageOptions < FriendlyShipping::PackageOptions
        attr_reader :package_code, :messages

        def initialize(package_code: nil, messages: [], **kwargs)
          @package_code = package_code
          @messages = messages
          super(**kwargs)
        end
      end
    end
  end
end
