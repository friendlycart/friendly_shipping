# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Serializes a shipment and options into a Reconex UpdateLoad request hash.
      class SerializeUpdateLoadRequest < SerializeCreateLoadRequest
        class << self
          # @param shipment [Physical::Shipment] the shipment to serialize
          # @param options [UpdateLoadOptions] the update load options
          # @return [Hash] the serialized request hash
          def call(shipment:, options:)
            deep_compact(
              action: serialize_action(options),
              emailParameters: serialize_email_parameters(options),
              loadDetails: serialize_load_details(options),
              billingLocation: serialize_billing_location(options.billing_location),
              originLocation: serialize_origin(shipment.origin, options),
              destinationLocation: serialize_destination(shipment.destination, options),
              accessorials: serialize_accessorials(options.accessorials),
              items: serialize_items(shipment, options),
              additionalLoadInfo: serialize_additional_load_info(options)
            )
          end

          private

          # @param options [UpdateLoadOptions]
          # @return [Hash]
          def serialize_action(options)
            super.merge(loadId: options.load_id)
          end

          # @param options [UpdateLoadOptions]
          # @return [Hash]
          def serialize_load_details(options)
            super.merge(
              billingID: options.billing_id,
              proNumber: options.pro_number
            )
          end

          # @param options [UpdateLoadOptions]
          # @return [Hash, nil]
          def serialize_email_parameters(options)
            return if [options.email_from, options.email_to, options.email_subject, options.email_body].all?(&:nil?)

            {
              emailFrom: options.email_from,
              emailTo: options.email_to,
              emailSubject: options.email_subject,
              emailBody: options.email_body
            }
          end
        end
      end
    end
  end
end
