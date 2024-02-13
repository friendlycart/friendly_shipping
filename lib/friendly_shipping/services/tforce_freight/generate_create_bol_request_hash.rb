# frozen_string_literal: true

require 'friendly_shipping/services/tforce_freight/generate_location_hash'

module FriendlyShipping
  module Services
    class TForceFreight
      # Generate a TForceFreight BOL request hash for JSON serialization.
      class GenerateCreateBOLRequestHash
        class << self
          # @param shipment [Physical::Shipment] the shipment for which we want to create a BOL
          # @param options [BOLOptions] options for the BOL
          # @return [Hash]
          def call(shipment:, options:)
            {
              requestOptions: request_options(options),
              shipFrom: location(shipment.origin),
              shipTo: location(shipment.destination),
              payment: payment(shipment.origin, options),
              commodities: options.commodity_information_generator.call(shipment: shipment, options: options),
              instructions: instructions(options),
              serviceOptions: service_options(options),
              pickupRequest: pickup_request(shipment.origin, options),
              documents: { image: documents(options.document_options) }
            }.compact.
              merge(GenerateHandlingUnitsHash.call(shipment: shipment, options: options)).
              merge(GenerateReferenceHash.call(reference_numbers: options.reference_numbers))
          end

          private

          # @param options [BOLOptions]
          # @return [Hash]
          def request_options(options)
            {
              serviceCode: options.service_code,
              pickupDate: options.pickup_at&.strftime("%Y-%m-%d"),
              previewRate: options.preview_rate,
              timeInTransit: options.time_in_transit
            }.compact
          end

          # @param location [Physical::Location]
          # @return [Hash]
          def location(location)
            {
              name: location.company_name.presence || location.name,
              contact: location.name,
              email: location.email,
              phone: { number: location.phone },
              address: {
                addressLine: address_line(location),
                city: location.city,
                stateProvinceCode: location.region&.code,
                postalCode: location.zip,
                country: location.country&.code
              }.compact,
              isResidential: location.residential?
            }.compact
          end

          # @param location [Physical::Location]
          # @param options [BOLOptions]
          # @return [Hash]
          def payment(location, options)
            {
              payer: {
                name: location.company_name.presence || location.name,
                contact: location.name,
                email: location.email,
                phone: { number: location.phone }.compact,
                address: {
                  addressLine: address_line(location),
                  city: location.city,
                  stateProvinceCode: location.region&.code,
                  postalCode: location.zip,
                  country: location.country&.code
                }.compact
              }.compact_blank,
              billingCode: options.billing_code
            }
          end

          # @param location [Physical::Location]
          def address_line(location)
            [
              location.address1,
              location.address2,
              location.address3
            ].compact.reject(&:blank?).join(" ").presence
          end

          # @param options [BOLOptions]
          # @return [Hash]
          def instructions(options)
            {
              pickup: options.pickup_instructions,
              handling: options.handling_instructions,
              delivery: options.delivery_instructions
            }.compact
          end

          # @param options [BOLOptions]
          # @return [Hash]
          def service_options(options)
            {
              pickup: options.pickup_options,
              delivery: options.delivery_options
            }
          end

          # @param location [Physical::Location]
          # @param options [PickupOptions]
          # @return [Hash]
          def pickup_request(location, options)
            {
              pickup: pickup(options),
              requester: requester(location),
              pomIndicator: false # We don't support this yet
            }
          end

          # @param options [PickupOptions]
          # @return [Hash]
          def pickup(options)
            {
              date: options.pickup_at&.strftime("%Y-%m-%d"),
              time: options.pickup_at&.strftime("%H:%M:%S"),
              openTime: options.pickup_time_window&.begin&.strftime("%H:%M:%S"),
              closeTime: options.pickup_time_window&.end&.strftime("%H:%M:%S")
            }.compact
          end

          # @param location [Physical::Location]
          # @return [Hash]
          def requester(location)
            {
              companyName: location.company_name.presence || location.name,
              contactName: location.name,
              email: location.email,
              phone: { number: location.phone }.compact
            }.compact
          end

          # @param document_options [Array<DocumentOptions>]
          # @return [Array<Hash>]
          def documents(document_options)
            document_options.map { GenerateDocumentOptionsHash.call(document_options: _1) }
          end
        end
      end
    end
  end
end
