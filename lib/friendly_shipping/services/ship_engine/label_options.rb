# frozen_string_literal: true

require 'friendly_shipping/shipment_options'
require 'friendly_shipping/services/ship_engine/label_customs_options'
require 'friendly_shipping/services/ship_engine/customs_items_serializer'

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for generating ShipEngine labels
      #
      # @attribute label_format [Symbol] The format for the label. Possible Values: :png, :zpl and :pdf. Default :pdf
      # @attribute label_download_type [Symbol] Whether to download directly (`:inline`) or
      #   obtain a URL to the label (`:url`). Default :url
      # @attribute label_image_id [String] Identifier for image uploaded to ShipEngine. Default: nil
      # @attribute package_options [Enumberable<LabelPackageOptions>] Package options for the packages in the shipment
      # @param [Callable] customs_items_serializer A callable that takes packages and an options object
      #   to create the customs items array for the shipment
      #
      class LabelOptions < FriendlyShipping::ShipmentOptions
        attr_reader :shipping_method,
                    :label_download_type,
                    :label_format,
                    :label_image_id,
                    :customs_options,
                    :customs_items_serializer

        def initialize(
          shipping_method:,
          label_download_type: :url,
          label_format: :pdf,
          label_image_id: nil,
          customs_options: LabelCustomsOptions.new,
          customs_items_serializer: CustomsItemsSerializer,
          **kwargs
        )
          @shipping_method = shipping_method
          @label_download_type = label_download_type
          @label_format = label_format
          @label_image_id = label_image_id
          @customs_options = customs_options
          @customs_items_serializer = customs_items_serializer
          super(**kwargs.reverse_merge(package_options_class: LabelPackageOptions))
        end
      end
    end
  end
end
