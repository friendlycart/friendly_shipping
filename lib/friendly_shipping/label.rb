# frozen_string_literal: true

require 'friendly_shipping/types'

module FriendlyShipping
  class Label
    attr_reader :id,
                :shipment_id,
                :tracking_number,
                :service_code,
                :label_href,
                :data,
                :label_format,
                :cost,
                :shipment_cost,
                :label_data

    # @param [String] id The label's ID
    # @param [String] shipment_id The label's shipment ID
    # @param [String] tracking_number The label's tracking number
    # @param [String] service_code The label's service code
    # @param [String] label_href The URL for the label
    # @param [String] label_format The label's format
    # @param [String] label_data The raw label data
    # @param [Money] shipment_cost The cost of the shipment
    # @param [Hash] data Additional data related to the label
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
