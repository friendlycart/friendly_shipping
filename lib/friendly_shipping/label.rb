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
