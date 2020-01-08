# frozen_string_literal: true

require 'friendly_shipping/services/ups/label_item_options'

module FriendlyShipping
  module Services
    class Ups
      # Package properties relevant for generating a UPS shipping label
      #
      # @option reference_numbers [Hash] a Hash where keys are _reference number codes_ and
      #   values are _reference number values_. Example: `{ reference_numbers: { xn: 'my_reference_1 }`
      # @option delivery_confirmation [Symbol] Can be set to any key from PACKAGE_DELIVERY_CONFIRMATION_CODES.
      #   Only possible for domestic shipments or shipments between the US and Puerto Rico.
      # @option shipper_release [Boolean] Indicates that the package may be released by driver without a signature from the
      #   consignee. Default: false
      class LabelPackageOptions < FriendlyShipping::PackageOptions
        PACKAGE_DELIVERY_CONFIRMATION_CODES = {
          delivery_confirmation: 1,
          delivery_confirmation_signature_required: 2,
          delivery_confirmation_adult_signature_required: 3
        }.freeze

        attr_reader :reference_numbers, :shipper_release

        def initialize(
          reference_numbers: {},
          delivery_confirmation: nil,
          shipper_release: false,
          **kwargs
        )
          @reference_numbers = reference_numbers
          @delivery_confirmation = delivery_confirmation
          @shipper_release = shipper_release
          super(**kwargs.merge(item_options_class: LabelItemOptions))
        end

        def delivery_confirmation_code
          PACKAGE_DELIVERY_CONFIRMATION_CODES[delivery_confirmation]
        end

        private

        attr_reader :delivery_confirmation
      end
    end
  end
end
