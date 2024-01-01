# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for obtaining international shipment labels with customs.
      class LabelCustomsOptions
        # @return [String] the contents of the shipment
        attr_reader :contents

        # @return [String] indicates what should be done if the shipment cannot be delivered
        attr_reader :non_delivery

        # @param contents [String] the contents of the shipment. Valid values are: gift, merchandise,
        #   returned_goods, documents, sample
        # @param non_delivery [String] indicates what should be done if the shipment cannot be delivered.
        #   Valid values are: treat_as_abandoned, return_to_sender
        def initialize(
          contents: "merchandise",
          non_delivery: "return_to_sender"
        )
          @contents = contents
          @non_delivery = non_delivery
        end
      end
    end
  end
end
