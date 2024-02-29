# frozen_string_literal: true

require 'friendly_shipping/services/ups_json/generate_address_hash'
require 'friendly_shipping/services/ups_json/generate_package_hash'

module FriendlyShipping
  module Services
    class UpsJson
      class GenerateLabelsPayload
        class << self
          def call(shipment:, options:)
            payload = initialize_payload(shipment, options)
            apply_options(payload, options)
            apply_international_forms_options(payload, shipment, options) if international?(shipment)
            add_packages(payload, shipment, options)
            add_label_specification(payload, options)
            payload.compact
          end

          def initialize_payload(shipment, options)
            contents_description = shipment.packages.flat_map do |package|
              package.items.map(&:description)
            end.compact.uniq.join(', ').slice(0, 50)

            {
              ShipmentRequest: {
                Request: {
                  RequestOption: options.validate_address ? "validate" : "nonvalidate",
                  SubVersion: options.sub_version
                },
                Shipment: {
                  Description: contents_description,
                  Service: {
                    Code: options.shipping_method.service_code
                  },
                  Shipper: GenerateAddressHash.call(location: options.shipper || shipment.origin, international: international?(shipment), shipper_number: options.shipper_number),
                  ShipTo: GenerateAddressHash.call(location: shipment.destination, international: international?(shipment)),
                  ShipmentDate: Time.current.strftime("%Y%m%d"),
                  PaymentInformation: {
                    ShipmentCharge: [
                      {
                        Type: "01", # Transportation
                        BillShipper: {
                          AccountNumber: options.shipper_number
                        }
                      }
                    ]
                  }
                }
              }
            }
          end

          def apply_options(payload, options)
            if options.customer_context.present?
              payload[:ShipmentRequest][:Request][:TransactionReference] = { CustomerContext: options.customer_context }
            end

            if options.negotiated_rates
              payload[:ShipmentRequest][:Shipment][:ShipmentRatingOptions] = { NegotiatedRatesIndicator: "X" }
            end

            payload[:ShipmentRequest][:Shipment][:ShipmentServiceOptions] = {
              UPScarbonneutralIndicator: options.carbon_neutral ? "X" : nil,
              SaturdayDeliveryIndicator: options.saturday_delivery ? "X" : nil,
              LabelDelivery: {
                LabelLinksIndicator: "X"
              }
            }.compact
          end

          def apply_international_forms_options(payload, shipment, options)
            if options.terms_of_shipment_code == "DDP"
              payload[:ShipmentRequest][:Shipment][:PaymentInformation][:ShipmentCharge].append(build_ddp_billing_info(options))
            end

            if options.paperless_invoice
              payload[:ShipmentRequest][:Shipment][:ShipmentServiceOptions][:InternationalForms] = international_forms(shipment, options)
            end

            sold_to_location = options.sold_to || shipment.destination

            international_forms_additions = {}
            international_forms_additions[:Contacts] = { SoldTo: GenerateAddressHash.call(location: sold_to_location, international: true) }
            international_forms_additions[:Contacts][:SoldTo].merge(
              {
                Phone: { Number: sold_to_location.phone },
                TaxIdentificationNumber: sold_to_location.try(:tax_id_number),
                EmailAddress: sold_to_location.email
              }
            ).compact
            payload[:ShipmentRequest][:Shipment][:ShipmentServiceOptions][:InternationalForms].merge!(international_forms_additions)

            return unless shipment.origin.country.code == "US" && ["CA", "PR"].include?(shipment.destination.country.code)

            # Required for shipments from the US to Canada or Puerto Rico
            # We'll assume USD as the origin country is the United States here.
            total_value = shipment.packages.inject(Money.new(0, "USD")) do |shipment_sum, package|
              shipment_sum + package.items.inject(Money.new(0, "USD")) do |package_sum, item|
                package_sum + (item.cost || Money.new(0, "USD"))
              end
            end
            payload[:ShipmentRequest][:Shipment][:InvoiceLineTotal] = {
              CurrencyCode: total_value.currency.iso_code,
              MonetaryValue: total_value.to_f.to_s
            }
          end

          def international?(shipment)
            shipment.origin.country != shipment.destination.country
          end

          def build_ddp_billing_info(options)
            billing_options = options.billing_options
            {
              Type: "02", # Duties and taxes
              BillThirdParty: {
                AccountNumber: billing_options.billing_account,
                Address: {
                  PostalCode: billing_options.billing_zip,
                  CountryCode: billing_options.billing_country
                }
              }
            }
          end

          def international_forms(shipment, options)
            invoice_date = options.invoice_date || Date.current
            result = {
              FormType: "01", # 01 is "Invoice"
              InvoiceDate: invoice_date.strftime("%Y%m%d"),
              ReasonForExport: options.reason_for_export,
              CurrencyCode: options.billing_options.currency || "USD",
              DeclarationStatement: options.declaration_statement,
              TermsOfShipment: options.terms_of_shipment_code,
              Product: []
            }.compact

            all_items = shipment.packages.map(&:items).map(&:to_a).flatten
            all_item_options = shipment.packages.flat_map do |package|
              package_options = options.options_for_package(package)
              package.items.flat_map do |item|
                package_options.options_for_item(item)
              end
            end

            all_items.group_by(&:description).each do |description, items|
              # This is a group of identically described items
              reference_item = items.first
              cost = reference_item.cost || Money.new(0, "USD")
              # Get the options for this item
              item_options = all_item_options.detect { |o| o.item_id == reference_item.id } || LabelItemOptions.new(item_id: nil)

              product_hash = {
                Description: description&.slice(0, 35), # Description of the product. Applies to all International Forms. Optional for Partial Invoice. Must be present at least once and can occur for a maximum of 3 times.
                CommodityCode: item_options.commodity_code,
                OriginCountryCode: item_options.country_of_origin || shipment.origin.country.code,
                Unit: {
                  Number: items.length.to_s,
                  UnitOfMeasurement: {
                    Code: item_options.product_unit_of_measure_code
                  },
                  Value: cost.to_d
                }
              }

              result[:Product] << product_hash
            end
            result
          end

          def add_packages(payload, shipment, options)
            payload[:ShipmentRequest][:Shipment][:Package] = shipment.packages.map do |package|
              package_options = options.options_for_package(package)
              delivery_confirmation_code = package_level_delivery_confirmation?(shipment) ? package_options.delivery_confirmation_code : nil

              GeneratePackageHash.call(
                package: package,
                delivery_confirmation_code: delivery_confirmation_code,
                shipper_release: package_options.shipper_release,
                declared_value: package_options.declared_value,
                package_flavor: 'labels'
              )
            end
          end

          def add_label_specification(payload, options)
            payload[:ShipmentRequest][:LabelSpecification] = {
              LabelImageFormat: {
                Code: options.label_format
              },
              LabelStockSize: {
                Width: options.label_size[0].to_s, # "Valid value is 4."
                Height: options.label_size[1].to_s # "Only valid values are 6 or 8."
              }
            }
          end

          # For certain origin/destination pairs, UPS allows each package in a shipment to have a specified
          # delivery_confirmation option otherwise the delivery_confirmation option must be specified on the entire shipment.
          # See https://developer.ups.com/api/reference/rating/appendix?loc=en_US for details
          def package_level_delivery_confirmation?(shipment)
            origin, destination = shipment.origin.country.code, shipment.destination.country.code
            origin == destination || [['US', 'PR'], ['PR', 'US']].include?([origin, destination])
          end
        end
      end
    end
  end
end
