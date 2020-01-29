# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class LabelDocumentOptions
        attr_reader :format, :type, :length, :width, :thermal

        DOCUMENT_TYPES = {
          label: "30",
          ups_bol: "20",
          vics_bol: "21"
        }.freeze

        DOCUMENT_FORMATS = {
          pdf: "01"
        }.freeze

        THERMAL_CODE = {
          false => "01",
          true => "02"
        }.freeze

        def initialize(
          format: :pdf,
          type: :label,
          size: "4x6",
          thermal: false,
          labels_per_page: 1
        )
          @format = format
          @type = type
          @length, @width = size.split('x').sort
          @thermal = thermal
          @labels_per_page = labels_per_page
        end

        def format_code
          DOCUMENT_FORMATS.fetch(format)
        end

        def document_type_code
          DOCUMENT_TYPES.fetch(type)
        end

        def thermal_code
          THERMAL_CODE.fetch(thermal)
        end

        def labels_per_page
          @labels_per_page.to_s
        end
      end
    end
  end
end
