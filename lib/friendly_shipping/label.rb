# frozen_string_literal: true

module FriendlyShipping
  class Label
    attr_reader :id,
                :shipment_id,
                :tracking_number,
                :service_code,
                :label_href,
                :data,
                :label_format,
                :shipment_cost,
                :label_data,
                :original_request,
                :original_response

    # @param [Integer] id The label's ID
    # @param [Integer] shipment_id The label's shipment ID
    # @param [String] tracking_number The label's tracking number
    # @param [String] service_code The label's service code
    # @param [String] label_href The URL for the label
    # @param [String] label_format The label's format
    # @param [String] label_data The raw label data
    # @param [Float] shipment_cost The cost of the shipment
    # @param [Hash] data Additional data related to the label
    # @param [FriendlyShipping::Request] original_request The HTTP request used to obtain the label
    # @param [FriendlyShipping::Response] original_response The HTTP response for the label
    def initialize(
      id: nil,
      shipment_id: nil,
      tracking_number: nil,
      service_code: nil,
      label_href: nil,
      label_format: nil,
      label_data: nil,
      shipment_cost: nil,
      data: {},
      original_request: nil,
      original_response: nil
    )
      @id = id
      @shipment_id = shipment_id
      @tracking_number = tracking_number
      @service_code = service_code
      @label_href = label_href
      @label_format = label_format
      @shipment_cost = shipment_cost
      @label_data = label_data
      @data = data
      @original_request = original_request
      @original_response = original_response
    end
  end
end
