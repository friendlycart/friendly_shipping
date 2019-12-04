# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      # Options for getting timing information from UPS
      # @attribute [Time] pickup When the shipment will be picked up
      # @attribute [Money] invoice_total How much the items in the shipment are worth
      #   As this is not super important for getting timing information, we use a default
      #   value of 50 USD here.
      # @attribute [Boolean] documents_only Does the shipment only contain documents?
      # @attribute [String] customer_context A string to connect request and response in the calling code
      class TimingOptions
        attr_reader :pickup,
                    :invoice_total,
                    :documents_only,
                    :customer_context

        def initialize(
          pickup: Time.now,
          invoice_total: Money.new(5000, 'USD'),
          documents_only: false,
          customer_context: nil
        )
          @pickup = pickup
          @invoice_total = invoice_total
          @documents_only = documents_only
          @customer_context = customer_context
        end
      end
    end
  end
end
