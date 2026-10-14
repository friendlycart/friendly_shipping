# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Options for getting timing information from UPS
      # @option pickup [Time] When the shipment will be picked up. Default: the current time
      # @option invoice_total [Money] How much the items in the shipment are worth
      #   As this is not super important for getting timing information, we use a default
      #   value of 50 USD here.
      # @option documents_only [Boolean] Does the shipment only contain documents?
      # @option customer_context [String] A string to connect request and response in the calling code
      class TimingsOptions
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
