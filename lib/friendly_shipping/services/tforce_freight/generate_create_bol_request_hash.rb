# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Generates a Bill of Lading (BOL) request hash for JSON serialization.
      class GenerateCreateBOLRequestHash
        class << self
          # @param shipment [Physical::Shipment] the shipment for which we want to create a BOL
          # @param options [BOLOptions] options for the BOL
          # @return [Hash] BOL request hash
          def call(shipment:, options:)
            origin = shipment.origin
            destination = shipment.destination
            {
              requestOptions: request_options(options),
              shipFrom: location(origin).merge(isResidential: origin.residential?),
              shipTo: location(destination).merge(isResidential: destination.residential?),
              payment: payment(origin, options),
              commodities: options.commodity_information_generator.call(shipment: shipment, options: options),
              instructions: instructions(options),
              serviceOptions: service_options(options),
              pickupRequest: pickup_request(origin, options),
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
              densityEligible: options.density_eligible || nil,
              previewRate: options.preview_rate,
              timeInTransit: options.time_in_transit
            }.compact
          end

          # @param location [Physical::Location]
          # @return [Hash]
          def location(location)
            {
              name: truncate(location.company_name.presence || location.name),
              contact: truncate(location.name),
              email: truncate(location.email, length: 50),
              phone: {
                number: truncate(location.phone, length: 15)
              }.compact,
              address: {
                addressLine: truncate(address_line(location)),
                city: location.city,
                stateProvinceCode: location.region&.code,
                postalCode: truncate(location.zip, length: 6),
                country: location.country&.code
              }.compact
            }.compact_blank
          end

          # @param location [Physical::Location]
          # @param options [BOLOptions]
          # @return [Hash]
          def payment(location, options)
            {
              payer: location(location),
              billingCode: options.billing_code
            }
          end

          # @param location [Physical::Location]
          # @return [String, nil]
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
              companyName: truncate(location.company_name.presence || location.name),
              contactName: truncate(location.name),
              email: truncate(location.email, length: 50),
              phone: {
                number: truncate(location.phone, length: 15)
              }.compact
            }.compact
          end

          # @param document_options [Array<DocumentOptions>]
          # @return [Array<Hash>]
          def documents(document_options)
            document_options.map { GenerateDocumentOptionsHash.call(document_options: _1) }
          end

          # @param value [String]
          # @param length [Integer]
          # @return [String]
          def truncate(value, length: 35)
            value && value[0..(length - 1)].strip
          end
        end
      end
    end
  end
end
