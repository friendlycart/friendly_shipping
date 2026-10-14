# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Parses a RateModifier hash from a UPS rates response into a label and an amount.
      class ParseRateModifierHash
        # @param rate_modifier [Hash, nil] the RateModifier hash from the source JSON
        # @param currency_code [String] the currency code for this modifier's amount (e.g. 'USD')
        # @return [Array(String, Money), nil] the label and the amount of the rate modifier, or nil if the
        #   modifier is missing or its amount is zero
        def self.call(rate_modifier, currency_code:)
          return unless rate_modifier

          amount = rate_modifier['Amount'].to_d
          return if amount.zero?

          currency = Money::Currency.new(currency_code)
          amount = Money.new(amount * currency.subunit_to_unit, currency)

          modifier_type = rate_modifier['ModifierType']
          modifier_description = rate_modifier['ModifierDesc']
          label = "#{modifier_type} (#{modifier_description})"

          [label, amount]
        end
      end
    end
  end
end
