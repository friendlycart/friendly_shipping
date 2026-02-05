# frozen_string_literal: true

module FriendlyShipping
  module Services
    class G2Mint
      module REST
        # Generates a rates request hash for JSON serialization.
        class GenerateRatesRequestHash
          class << self
            # @param shipment [Physical::Shipment] the shipment for which we want to get rates
            # @param options [RatesOptions] options for obtaining rates for this shipment
            # @return [Hash] rates request hash
            def call(shipment:, options:)
              {
                requestId: options.request_id,
                isSync: true,
                # consolidateSaving: false, ignore
                requestIdType: "SHIPMENT",
                transportationModes: options.transportation_modes,
                accessorials: options.accessorials,
                stops: generate_stops(shipment, options),
                packagingUnits: options.packaging_unit_generator.call(shipment: shipment, options: options),
                handlingUnits: options.handling_unit_generator.call(shipment: shipment, options: options),
                commodities: options.commodity_information_generator.call(shipment: shipment, options: options),
                uom: {
                  length: "IN",
                  weight: "LB"
                },
                distance: options.distance,
                direction: options.direction,
                freightTerms: options.freight_terms,
                accountID: options.account_id,
                ownerTenant: options.owner_tenant,
                billTo: generate_bill_to(options),
                declaredValue: nil
              }.compact
            end

            private

            # @param shipment [Physical::Shipment]
            # @param options [RatesOptions]
            # @return [Array<Hash>]
            def generate_stops(shipment, options)
              [
                generate_pickup_stop(shipment.origin, options),
                generate_delivery_stop(shipment.destination, options)
              ]
            end

            # @param location [Physical::Location]
            # @param options [RatesOptions]
            # @return [Hash]
            def generate_pickup_stop(location, options)
              pickup_date = options.pickup_date.strftime('%Y-%m-%dT00:00:00.000Z')
              time_window = options.pickup_time_window || {}

              {
                address: GenerateLocationHash.call(location: location),
                expectedStart: {
                  date: pickup_date,
                  time: time_window[:start] || ""
                },
                expectedEnd: {
                  date: pickup_date,
                  time: time_window[:end] || ""
                },
                type: "PICKUP",
                accessorials: [],
                contact: options.pickup_contact || generate_default_contact,
                sequence: 1,
                note: options.pickup_note || ""
              }.compact
            end

            # @param location [Physical::Location]
            # @param options [RatesOptions]
            # @return [Hash]
            def generate_delivery_stop(location, options)
              time_window = options.delivery_time_window || {}

              {
                address: GenerateLocationHash.call(location: location),
                expectedStart: {
                  date: time_window[:start_date] || "",
                  time: time_window[:start] || ""
                },
                expectedEnd: {
                  date: time_window[:end_date] || "",
                  time: time_window[:end] || ""
                },
                type: "DELIVERY",
                accessorials: [],
                contact: options.delivery_contact || generate_default_contact,
                sequence: 2,
                note: options.delivery_note
              }.compact
            end

            # @param options [RatesOptions]
            # @return [Hash]
            def generate_bill_to(options)
              {
                location: {
                  id: options.bill_to_location_id,
                  name: options.bill_to_location_name
                }.compact,
                address: GenerateLocationHash.call(location: options.bill_to_location),
                contact: options.bill_to_contact
              }.compact
            end

            # @return [Hash]
            def generate_default_contact
              {
                firstName: "",
                lastName: "",
                phoneNumber: nil,
                email: ""
              }
            end
          end
        end
      end
    end
  end
end
