# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Serializes options into a Reconex GetLoadInfo request hash.
      class SerializeLoadInfoRequest
        class << self
          # @param options [LoadInfoOptions] the load info options
          # @return [Hash] the serialized request hash
          def call(options:)
            {
              loadsId: options.load_ids.presence,
              loadsReference: serialize_references(options.references),
              statusLoads: options.status_filters.presence,
              loadInfoDocuments: {
                getBillOfLadingDocument: options.get_bill_of_lading,
                getShippingLabelDocument: {
                  isRequiered: options.get_shipping_label,
                  reportTypeId: options.shipping_label_report_type_id
                },
                getRateConfirmationDocument: options.get_rate_confirmation,
                getCarrieDocsFile: options.get_carrier_docs_file,
                getFreightSnapDocuments: options.get_freight_snap_documents
              }
            }
          end

          private

          # @param references [Array<Hash>] the references to serialize
          # @return [Array<Hash>, nil]
          def serialize_references(references)
            return if references.empty?

            references.map do |ref|
              {
                billingId: ref[:billing_id],
                poNumber: ref[:po_number],
                customerId: ref[:customer_id],
                customerBillingId: ref[:customer_billing_id]
              }
            end
          end
        end
      end
    end
  end
end
