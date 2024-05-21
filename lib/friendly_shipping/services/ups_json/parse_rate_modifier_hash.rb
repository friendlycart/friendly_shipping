# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class ParseRateModifierHash
        # @param [Hash] hash the RateModifier hash from the source JSON
        # @param [String] currency_code The currency code for this modifier's amount (i.e. 'USD')
        # @return [Array] The label and the amount of the rate modifier
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
