# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      # Represents customs options for obtaining international shipment labels.
      # @option contents [String] The contents of the shipment.
      #  Valid values are: gift, merchandise, returned_goods, documents, sample
      # @option non_delivery [String] Indicates what should be done if the shipment cannot be delivered.
      #  Valid values are: treat_as_abandoned, return_to_sender
      class LabelCustomsOptions
        attr_reader :contents,
                    :non_delivery

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
