# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Options for getting documents (BOLs, labels, etc.) from the API.
      class DocumentOptions
        # @return [Symbol] the document type (see {DOCUMENT_TYPES})
        attr_reader :type

        # @return [Symbol] the document format (see {DOCUMENT_FORMATS})
        attr_reader :format

        # @return [Boolean] whether or not the label is for thermal printers (DEPRECATED: use `label_type` instead)
        attr_reader :thermal

        # @return [String] the type of label
        attr_reader :label_type

        # @return [Integer] the start position of the sticker
        attr_reader :start_position

        # @return [Integer] the number of stickers
        attr_reader :number_of_stickers

        # Maps friendly names to document types.
        DOCUMENT_TYPES = {
          label: "30",
          tforce_bol: "20",
          vics_bol: "21"
        }.freeze

        # Maps friendly names to document formats.
        DOCUMENT_FORMATS = {
          pdf: "01"
        }.freeze

        # Maps booleans to thermal codes.
        THERMAL_CODE = {
          false => "01",
          true => "02"
        }.freeze

        # Maps friendly names to label types.
        LABEL_TYPE_CODES = {
          address_labels_with_pro_nums: "01",
          address_labels_without_pro_nums: "02",
          pro_stickers: "03",
          address_labels_1x1: "04",
          address_labels_2x1: "05",
          address_labels_2x2: "06",
          thermal_labels_4x6: "07",
          thermal_labels_4x8: "08"
        }.freeze

        # @param type [Symbol] the document type (see [DOCUMENT_TYPES])
        # @param format [Symbol] the document format (see [DOCUMENT_FORMATS])
        # @param thermal [Boolean] whether or not the label is for thermal printers (DEPRECATED: use `label_type` instead)
        # @param start_position [Integer] the start position of the sticker
        # @param number_of_stickers [Integer] the number of stickers
        def initialize(
          type: :label,
          format: :pdf,
          thermal: false,
          label_type: :thermal_labels_4x6,
          start_position: 1,
          number_of_stickers: 1
        )
          @type = type
          @format = format
          @thermal = thermal
          @label_type = label_type
          @start_position = start_position
          @number_of_stickers = number_of_stickers
        end

        # @return [String]
        def format_code
          DOCUMENT_FORMATS.fetch(format)
        end

        # @return [String]
        def document_type_code
          DOCUMENT_TYPES.fetch(type)
        end

        # @return [String]
        # @deprecated Use `label_type` instead.
        def thermal_code
          THERMAL_CODE.fetch(thermal)
        end

        # @return [String]
        def label_type_code
          LABEL_TYPE_CODES.fetch(label_type)
        end
      end
    end
  end
end
