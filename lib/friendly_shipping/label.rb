module FriendlyShipping
  class Label
    attr_reader :id, :shipment_id, :tracking_number, :service_code, :label_href, :data, :label_format

    def initialize(id: nil, shipment_id: nil, tracking_number: nil, service_code: nil, label_href: nil, label_format: nil, data: {})
      @id = id
      @shipment_id = shipment_id
      @tracking_number = tracking_number
      @service_code = service_code
      @label_href = label_href
      @label_format = label_format
      @data = data
    end
  end
end
