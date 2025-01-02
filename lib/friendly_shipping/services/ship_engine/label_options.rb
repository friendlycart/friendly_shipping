# frozen_string_literal: true

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for generating shipping labels.
      class LabelOptions < FriendlyShipping::ShipmentOptions
        # @return [ShippingMethod] the label's shipping method
        attr_reader :shipping_method

        # @return [Symbol] whether to download directly or obtain a URL to the label
        attr_reader :label_download_type

        # @return [Symbol] the format for the label
        attr_reader :label_format

        # @return [String] identifier for image uploaded to ShipEngine
        attr_reader :label_image_id

        # @return [LabelCustomsOptions] customs options for international shipment labels
        attr_reader :customs_options

        # @return [Proc, #call] a callable that takes packages and an options object to create the customs items array for the shipment
        attr_reader :customs_items_serializer

        # @param shipping_method [ShippingMethod] the label's shipping method
        # @param label_download_type [Symbol] whether to download directly (`:inline`) or obtain a URL to the label (`:url`). Default :url
        # @param label_format [Symbol] the format for the label. Possible Values: :png, :zpl and :pdf. Default :pdf
        # @param label_image_id [String] identifier for image uploaded to ShipEngine. Default: nil
        # @param customs_options [LabelCustomsOptions] customs options for obtaining international shipment labels
        # @param customs_items_serializer [Proc, #call] a callable that takes packages and an options object to create the customs items array for the shipment
        # @param kwargs [Hash]
        # @option kwargs [Array<LabelPackageOptions>] :package_options package options for the packages in the shipment
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
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
