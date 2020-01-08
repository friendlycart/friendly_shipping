# frozen_string_literal: true

require 'friendly_shipping/shipment_options'

module FriendlyShipping
  module Services
    class ShipEngine
      # Options for generating ShipEngine labels
      #
      # @attribute label_format [Symbol] The format for the label. Possible Values: :png, :zpl and :pdf. Default :pdf
      # @attribute label_download_type [Symbol] Whether to download directly (`:inline`) or
      #   obtain a URL to the label (`:url`). Default :url
      # @attribute package_options [Enumberable<LabelPackageOptions>] Package options for the packages in the shipment
      #
      class LabelOptions < FriendlyShipping::ShipmentOptions
        attr_reader :shipping_method,
                    :label_format,
                    :label_download_type

        def initialize(
          shipping_method:,
          label_format: :pdf,
          label_download_type: :url,
          **kwargs
        )
          @shipping_method = shipping_method
          @label_format = label_format
          @label_download_type = label_download_type
          super(**kwargs.merge(package_options_class: LabelPackageOptions))
        end
      end
    end
  end
end
