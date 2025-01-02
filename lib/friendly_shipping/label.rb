# frozen_string_literal: true

module FriendlyShipping
  # Base class for a shipping label returned by a carrier API.
  class Label
    # @return [String] the label's unique ID
    attr_reader :id

    # @return [String] the label's shipment ID
    attr_reader :shipment_id

    # @return [String] the label's tracking number
    attr_reader :tracking_number

    # @return [String] the label's service code
    attr_reader :service_code

    # @return [String] the URL for the label
    attr_reader :label_href

    # @return [String] the label's format
    attr_reader :label_format

    # @return [String] the raw label data
    attr_reader :label_data

    # @return [Money] the label's cost
    attr_reader :cost

    # @return [Money] the overall cost of the shipment
    attr_reader :shipment_cost

    # @return [Hash] additional data related to the label
    attr_reader :data

    # @param id [String] the label's unique ID
    # @param shipment_id [String] the label's shipment ID
    # @param tracking_number [String] the label's tracking number
    # @param service_code [String] the label's service code
    # @param label_href [String] the URL for the label
    # @param label_format [String] the label's format
    # @param label_data [String] the raw label data
    # @param cost [Money] the label's cost
    # @param shipment_cost [Money] the overall cost of the shipment
    # @param data [Hash] additional data related to the label
    def initialize(
      id: nil,
      shipment_id: nil,
      tracking_number: nil,
      service_code: nil,
      label_href: nil,
      label_format: nil,
      label_data: nil,
      cost: nil,
      shipment_cost: nil,
      data: {}
    )
      @id = id
      @shipment_id = shipment_id
      @tracking_number = tracking_number
      @service_code = service_code
      @label_href = label_href
      @label_format = label_format
      @cost = FriendlyShipping::Types::Money.optional[cost]
      @shipment_cost = FriendlyShipping::Types::Money.optional[shipment_cost]
      @label_data = label_data
      @data = data
    end
  end
end
