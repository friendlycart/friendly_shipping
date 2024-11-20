# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Represents a label returned by the UPS JSON API.
      class Label < FriendlyShipping::Label
        # @return [String] the label's USPS tracking number
        attr_reader :usps_tracking_number

        # @param usps_tracking_number [String] the label's USPS tracking number (only applies to SurePost)
        # @param kwargs [Hash]
        # @option kwargs [String] :id the label's unique ID
        # @option kwargs [String] :shipment_id the label's shipment ID
        # @option kwargs [String] :tracking_number the label's tracking number
        # @option kwargs [String] :service_code the label's service code
        # @option kwargs [String] :label_href the URL for the label
        # @option kwargs [String] :label_format the label's format
        # @option kwargs [String] :label_data the raw label data
        # @option kwargs [Money] :cost the label's cost
        # @option kwargs [Money] :shipment_cost the overall cost of the shipment
        # @option kwargs [Hash] :data additional data related to the label
        def initialize(
          usps_tracking_number: nil,
          **kwargs
        )
          @usps_tracking_number = usps_tracking_number
          super(**kwargs)
        end
      end
    end
  end
end
