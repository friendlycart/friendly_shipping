# frozen_string_literal: true

require 'friendly_shipping/services/tforce_freight/generate_location_hash'

module FriendlyShipping
  module Services
    class TForceFreight
      # Generate a TForceFreight pickup request hash for JSON serialization.
      class GeneratePickupRequestHash
        class << self
          # @param shipment [Physical::Shipment] the shipment for which we want to create a pickup request
          # @param options [PickupOptions] options for the pickup request
          # @return [Hash]
          def call(shipment:, options:)
            {
              pickup: pickup(options),
              requester: requester(shipment.origin),
              origin: origin(shipment.origin),
              destination: destination(shipment.destination),
              services: options.service_options,
              lineItems: line_items(shipment.packages, options),
              instructions: instructions(options),
              pomIndicator: false # We don't support this yet
            }.compact
          end

          private

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

          # @param location [Physical::Location]
          # @return [Hash]
          def origin(location)
            {
              companyName: location.company_name.presence || location.name,
              contactName: location.name,
              email: location.email,
              phone: { number: location.phone },
              address: {
                address1: location.address1,
                address2: location.address2,
                address3: location.address3,
                city: location.city,
                stateProvinceCode: location.region&.code,
                postalCode: location.zip,
                country: location.country&.code
              }.compact
            }.compact
          end

          # @param location [Physical::Location]
          # @return [Hash]
          def destination(location)
            {
              postalCode: location.zip,
              country: location.country&.code
            }.compact
          end

          # @param packages [Array<Physical::Package>]
          # @param options [Physical::Location]
          # @return [Array<Hash>]
          def line_items(packages, options)
            packages.flat_map do |package|
              package_options = options.options_for_package(package)
              package.items.map do |item|
                item_options = package_options.options_for_item(item)
                {
                  description: item.description.presence || "Commodities",
                  weight: item.weight.convert_to(:pounds).value.to_f.ceil,
                  weightUnit: "LBS",
                  pieces: 1,
                  packagingType: item_options.packaging_code,
                  hazardous: item_options.hazardous
                }.compact
              end
            end
          end

          # @param options [PickupOptions]
          # @return [Hash]
          def instructions(options)
            {
              pickup: options.pickup_instructions,
              handling: options.handling_instructions,
              delivery: options.delivery_instructions
            }.compact
          end
        end
      end
    end
  end
end
