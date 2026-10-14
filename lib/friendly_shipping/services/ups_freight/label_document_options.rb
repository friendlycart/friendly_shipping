# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for a label or document image requested in a UPS Freight ship request.
      class LabelDocumentOptions
        # @return [Symbol] the document format (a key of {DOCUMENT_FORMATS})
        attr_reader :format

        # @return [Symbol] the document type (a key of {DOCUMENT_TYPES})
        attr_reader :type

        # @return [String] the smaller dimension of the size, as given
        attr_reader :length

        # @return [String] the larger dimension of the size, as given
        attr_reader :width

        # @return [Boolean] whether a thermal label is requested
        attr_reader :thermal

        # Maps friendly names to document type codes.
        DOCUMENT_TYPES = {
          label: "30",
          ups_bol: "20",
          vics_bol: "21"
        }.freeze

        # Maps friendly names to document format codes.
        DOCUMENT_FORMATS = {
          pdf: "01"
        }.freeze

        # Maps the thermal flag to a print format code.
        THERMAL_CODE = {
          false => "01",
          true => "02"
        }.freeze

        # @param format [Symbol] the document format (see {DOCUMENT_FORMATS})
        # @param type [Symbol] the document type (see {DOCUMENT_TYPES})
        # @param size [String] the size as "AxB", for example "4x6"; the two numbers are sorted into length and width
        # @param thermal [Boolean] whether to request a thermal label
        # @param labels_per_page [Integer] the number of labels per page
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

        # @return [String] the code for {#format}
        def format_code
          DOCUMENT_FORMATS.fetch(format)
        end

        # @return [String] the code for {#type}
        def document_type_code
          DOCUMENT_TYPES.fetch(type)
        end

        # @return [String] the code for {#thermal}
        def thermal_code
          THERMAL_CODE.fetch(thermal)
        end

        # @return [String] the number of labels per page, as a string
        def labels_per_page
          @labels_per_page.to_s
        end
      end
    end
  end
end
