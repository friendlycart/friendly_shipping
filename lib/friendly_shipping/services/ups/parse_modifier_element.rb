# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class ParseModifierElement
        # @param [Nokogiri::XML::Element] element The modifier element from the source XML
        # @param [String] currency_code The currency code for this modifier's amount (i.e. 'USD')
        # @return [Array<String, Money>]
        def self.call(element, currency_code:)
          return unless element

          amount = element.at('Amount').text.to_d
          return if amount.zero?

          currency = Money::Currency.new(currency_code)
          amount = Money.new(amount * currency.subunit_to_unit, currency)

          modifier_type = element.at('ModifierType').text
          modifier_description = element.at('ModifierDesc').text

          label = "#{modifier_type} (#{modifier_description})"

          [label, amount]
        end
      end
    end
  end
end
