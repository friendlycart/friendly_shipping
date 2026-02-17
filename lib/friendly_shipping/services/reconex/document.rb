# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Represents a document (BOL, shipping label, etc.) returned from a Reconex API response.
      class Document
        # @return [Symbol] the document type (:bol, :label, :rate_confirmation, :carrier_docs)
        attr_reader :document_type

        # @return [String] the file name
        attr_reader :filename

        # @return [Symbol] the file format (e.g. :pdf)
        attr_reader :format

        # @return [String] the decoded binary content
        attr_reader :binary

        # @param document_type [Symbol] the document type
        # @param filename [String] the file name
        # @param format [Symbol] the file format
        # @param binary [String] the decoded binary content
        def initialize(document_type:, filename:, format:, binary:)
          @document_type = document_type
          @filename = filename
          @format = format
          @binary = binary
        end
      end
    end
  end
end
