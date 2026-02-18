# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Options for a Reconex GetLoadInfo request.
      class LoadInfoOptions
        # Valid load statuses for filtering.
        STATUSES = %w[Pending Quoted Booked Dispatched InTransit Delivered Canceled].freeze

        # Valid shipping label report type IDs. Controls PDF format for printing.
        SHIPPING_LABEL_REPORT_TYPES = {
          800 => "6x4, 1 Label/sheet, 4 per skid (Zebra Printer)",
          801 => "8.5x11, 1 Label/sheet, 1 per skid (Standard)",
          802 => "11x8.5, 4 Labels/sheet, 4 per skid (Avery 5168)",
          803 => "6x4, 1 Label/sheet, 1 per skid (Zebra Printer)",
          804 => "4x6, 1 Label/sheet, 4 per skid (Zebra Printer)",
          805 => "4x6, 1 Label/sheet, 2 per skid (Zebra Printer)",
          806 => "4x3.34, 1 Label/sheet, 4 per skid (Zebra Printer)",
          807 => "4x2.7, 1 Label/sheet, 4 per skid (Zebra Printer)",
          808 => "8.25x4, 1 Label/sheet, 1 per skid (Zebra Printer)",
          809 => "11x8.5, 1 Label/sheet, 1 per skid (Standard)",
          813 => "4x6, 1 Label/sheet, 1 per skid (Zebra Printer)",
          814 => "2x4, 1 Label/sheet, 2 per skid (Zebra Printer)",
          815 => "4x4, 1 Label/sheet, 4 per skid (Zebra Printer)",
          816 => "4x6.75, 1 Label/sheet, 1 per skid (Zebra Printer)"
        }.freeze

        # @return [Array<Integer>] load IDs to query
        attr_reader :load_ids

        # @return [Array<Hash>] reference lookups (keys: :billing_id, :po_number, :customer_id, :customer_billing_id)
        attr_reader :references

        # @return [Array<String>] status filters
        attr_reader :status_filters

        # @return [Boolean] whether to include BOL documents
        attr_reader :get_bill_of_lading

        # @return [Boolean] whether to include shipping label documents
        attr_reader :get_shipping_label

        # @return [Integer] the shipping label report type ID
        attr_reader :shipping_label_report_type_id

        # @return [Boolean] whether to include rate confirmation documents
        attr_reader :get_rate_confirmation

        # @return [Boolean] whether to include carrier docs
        attr_reader :get_carrier_docs_file

        # @return [Boolean] whether to include FreightSnap documents
        attr_reader :get_freight_snap_documents

        # @param load_ids [Array<Integer>] load IDs to query
        # @param references [Array<Hash>] reference lookups
        # @param status_filters [Array<String>] status filters
        # @param get_bill_of_lading [Boolean] whether to include BOL documents
        # @param get_shipping_label [Boolean] whether to include shipping label documents
        # @param shipping_label_report_type_id [Integer] the shipping label report type ID
        # @param get_rate_confirmation [Boolean] whether to include rate confirmation documents
        # @param get_carrier_docs_file [Boolean] whether to include carrier docs
        # @param get_freight_snap_documents [Boolean] whether to include FreightSnap documents
        def initialize(
          load_ids: [],
          references: [],
          status_filters: [],
          get_bill_of_lading: false,
          get_shipping_label: false,
          shipping_label_report_type_id: 802,
          get_rate_confirmation: false,
          get_carrier_docs_file: false,
          get_freight_snap_documents: false
        )
          @load_ids = load_ids
          @references = references
          @status_filters = status_filters
          @get_bill_of_lading = get_bill_of_lading
          @get_shipping_label = get_shipping_label
          @shipping_label_report_type_id = shipping_label_report_type_id
          @get_rate_confirmation = get_rate_confirmation
          @get_carrier_docs_file = get_carrier_docs_file
          @get_freight_snap_documents = get_freight_snap_documents
          validate_status_filters!
          validate_shipping_label_report_type_id!
        end

        private

        # @raise [ArgumentError] invalid status filter
        def validate_status_filters!
          invalid = status_filters - STATUSES
          return if invalid.empty?

          raise ArgumentError, "Invalid status filter(s): #{invalid.join(', ')}"
        end

        # @raise [ArgumentError] invalid shipping label report type ID
        def validate_shipping_label_report_type_id!
          return if SHIPPING_LABEL_REPORT_TYPES.key?(shipping_label_report_type_id)

          raise ArgumentError, "Invalid shipping label report type ID: #{shipping_label_report_type_id}"
        end
      end
    end
  end
end
