# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      # Package options for generating shipping labels.
      class LabelPackageOptions < FriendlyShipping::PackageOptions
        # @return [Symbol] the type of package
        attr_reader :package_code

        # @return [Array<String>] a list of messages to add to the label
        attr_reader :messages

        # @param package_code [Symbol] The type of package. Possible types can be gotten
        #    via the ShipEngine API: https://www.shipengine.com/docs/reference/list-carrier-packages/
        #    If a package type is given, no dimensions will be added to the call (as we can assume the
        #    carrier knows the dimensions of their packaging types).
        # @param messages [Array<String>] A list of messages to add to the label. No carrier accepts
        #    more than three messages, and some have restrictions on how many characters are possible.
        #    We're not validating here though.
        # @param kwargs [Hash]
        # @option kwargs [String] :package_id the ID for the package that belongs to these options
        # @option kwargs [Array<ItemOptions>] :item_options the options for items in this package
        # @option kwargs [Class] :item_options_class the class to use for item options when none are provided
        def initialize(package_code: nil, messages: [], **kwargs)
          @package_code = package_code
          @messages = messages
          super(**kwargs.reverse_merge(item_options_class: LabelItemOptions))
        end
      end
    end
  end
end
