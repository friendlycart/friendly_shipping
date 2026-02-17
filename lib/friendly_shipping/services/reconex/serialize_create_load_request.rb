# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Serializes a shipment and options into a Reconex CreateLoad request hash.
      class SerializeCreateLoadRequest
        class << self
          # @param shipment [Physical::Shipment] the shipment to serialize
          # @param options [LoadOptions] the load options
          # @return [Hash] the serialized request hash
          def call(shipment:, options:)
            deep_compact(
              action: serialize_action(options),
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

          # @param options [LoadOptions]
          # @return [Hash]
          def serialize_action(options)
            {
              accountId: options.account_id,
              rate: options.rate,
              book: options.scac,
              proNumber: options.pro_number_requested,
              dispatch: options.dispatch,
              errorEmailNotification: options.error_email
            }
          end

          # @param options [LoadOptions]
          # @return [Hash]
          def serialize_load_details(options)
            {
              poNumber: options.po_number,
              customID: options.custom_id,
              customerBilling: options.customer_billing
            }
          end

          # @param location [Physical::Location, nil]
          # @return [Hash, nil]
          def serialize_billing_location(location)
            return if location.nil?

            {
              name: location.company_name || location.name,
              street: location.address1,
              city: location.city,
              stateProvince: location.region.code,
              postalCode: location.zip,
              country: location.country.code
            }
          end

          # @param location [Physical::Location]
          # @param options [LoadOptions]
          # @return [Hash]
          def serialize_origin(location, options)
            {
              name: location.company_name || location.name,
              contact: location.name,
              street: location.address1,
              city: location.city,
              stateProvince: location.region.code,
              postalCode: location.zip,
              country: location.country.code,
              phone: location.phone,
              email: location.email,
              dockType: options.dock_type,
              notes: options.origin_notes,
              dockOpen: options.origin_dock_open&.iso8601,
              dockClose: options.origin_dock_close&.iso8601,
              appointment: options.origin_appointment,
              freightReadyTime: options.origin_freight_ready_time&.iso8601
            }
          end

          # @param location [Physical::Location]
          # @param options [LoadOptions]
          # @return [Hash]
          def serialize_destination(location, options)
            {
              name: location.company_name || location.name,
              contact: location.name,
              street: location.address1,
              city: location.city,
              stateProvince: location.region.code,
              postalCode: location.zip,
              country: location.country.code,
              phone: location.phone,
              email: location.email,
              dockType: options.destination_dock_type,
              notes: options.destination_notes,
              dockOpen: options.destination_dock_open&.iso8601,
              dockClose: options.destination_dock_close&.iso8601,
              appointment: options.destination_appointment
            }
          end

          # @param accessorials [Hash]
          # @return [Hash]
          def serialize_accessorials(accessorials)
            accessorials.transform_keys { |key| camelize(key.to_s) }
          end

          # @param shipment [Physical::Shipment]
          # @param options [LoadOptions]
          # @return [Array<Hash>]
          def serialize_items(shipment, options)
            shipment.structures.flat_map do |structure|
              structure_options = options.options_for_structure(structure)
              structure.packages.map do |package|
                package_options = structure_options.options_for_package(package)
                {
                  qty: "1",
                  packaging: package_options.packaging,
                  freightClass: package_options.freight_class,
                  weight: package.weight.convert_to(:lb).value.to_f.round(2).to_s,
                  nmfCnumber: package_options.nmfc_code,
                  subClass: package_options.sub_class,
                  description: package_options.description,
                  hazMat: { isHazMat: false },
                  itemDimensions: {
                    length: package.length.convert_to(:in).value.to_f.round.to_i,
                    height: package.height.convert_to(:in).value.to_f.round.to_i,
                    width: package.width.convert_to(:in).value.to_f.round.to_i,
                    shipQuantity: 1
                  }
                }
              end
            end
          end

          # @param options [LoadOptions]
          # @return [Hash]
          def serialize_additional_load_info(options)
            {
              pickedUpDate: options.pickup_date&.iso8601,
              mustArriveByDate: options.must_arrive_by_date&.iso8601,
              specialInstructions: options.special_instructions,
              shippingQuantity: options.shipping_quantity,
              loadEquipmentType: options.load_equipment_type,
              shippingUnits: options.shipping_units,
              allStackable: options.all_stackable,
              loadNotes: options.load_notes,
              asn: { isASNNeeded: options.asn_needed }
            }
          end

          # @param str [String] a snake_case string
          # @return [String] the camelCase version
          def camelize(str)
            parts = str.split("_")
            parts[0] + parts[1..].map(&:capitalize).join
          end

          # Recursively removes nil values from hashes and arrays.
          # @param object [Hash, Array, Object] the object to compact
          # @return [Hash, Array, Object] the compacted object
          def deep_compact(object)
            case object
            when Hash
              object.each_with_object({}) do |(key, value), result|
                next if value.nil?

                result[key] = deep_compact(value)
              end
            when Array
              object.map { |item| deep_compact(item) }
            else
              object
            end
          end
        end
      end
    end
  end
end
