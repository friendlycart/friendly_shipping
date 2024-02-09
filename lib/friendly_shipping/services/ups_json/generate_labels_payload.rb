# frozen_string_literal: true

require 'friendly_shipping/services/ups_json/generate_address_hash'
require 'friendly_shipping/services/ups_json/generate_package_hash'

module FriendlyShipping
  module Services
    class UpsJson
      class GenerateLabelsPayload
        def self.call(shipment:, options:)
          contents_description = shipment.packages.flat_map do |package|
            package.items.map(&:description)
          end.compact.uniq.join(', ').slice(0, 50)

          payload =
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

          payload[:ShipmentRequest][:Shipment][:ShipFrom]

          if options.customer_context.present?
            payload[:ShipmentRequest][:Request][:TransactionReference] = { CustomerContext: options.customer_context }
          end

          if options.shipper || options.return_service_code
            origin = options.return_service_code ? shipment.destination : shipment.origin
            payload[:ShipmentRequest][:Shipment][:ShipFrom] = GenerateAddressHash.call(location: origin, international: international?(shipment))
            payload[:ShipmentRequest][:Shipment][:ShipTo] = GenerateAddressHash.call(location: shipment.origin, international: international?(shipment))
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

          if international?(shipment) && options.terms_of_shipment_code == "DDP" && options.billing_options.bill_third_party
            payload[:ShipmentRequest][:Shipment][:PaymentInformation][:ShipmentCharge].append(build_ddp_billing_info(options))
          end

          if international?(shipment) && options.paperless_invoice
            payload[:ShipmentRequest][:Shipment][:ShipmentServiceOptions][:InternationalForms] = international_forms(shipment, options)
          end

          if international?(shipment)
            unless options.return_service_code
              international_forms_additions = {}
              sold_to_location = options.sold_to || shipment.destination
              international_forms_additions[:Contacts] = { SoldTo: GenerateAddressHash.call(location: sold_to_location, international: true) }
              international_forms_additions[:Contacts][:SoldTo].merge(
                {
                  Phone: { Number: sold_to_location.phone },
                  TaxIdentificationNumber: sold_to_location.try(:tax_id_number),
                  EmailAddress: sold_to_location.email
                }
              ).compact
              payload[:ShipmentRequest][:Shipment][:ShipmentServiceOptions][:InternationalForms].merge!(international_forms_additions)
            end

            if shipment.origin.country.code == 'US' && ['CA', 'PR'].include?(shipment.destination.country.code)
              # Required for shipments from the US to Puerto Rico or Canada
              # We'll assume USD as the origin country is the United States here.
              total_value = shipment.packages.inject(Money.new(0, 'USD')) do |shipment_sum, package|
                shipment_sum + package.items.inject(Money.new(0, 'USD')) do |package_sum, item|
                  package_sum + (item.cost || Money.new(0, 'USD'))
                end
              end
              payload[:ShipmentRequest][:Shipment][:InvoiceLineTotal] = {
                CurrencyCode: 'USD',
                MonetaryValue: total_value.to_f.to_s
              }
            end

            contents_description = shipment.packages.flat_map do |package|
              package.items.map(&:description)
            end.compact.uniq.join(', ').slice(0, 50)
            payload[:ShipmentRequest][:Shipment][:Description] = contents_description
          end

          if options.return_service_code
            payload[:ShipmentRequest][:Shipment][:ReturnService] = { Code: options.return_service_code.to_s }
            payload[:ShipmentRequest][:Shipment][:ShipmentServiceOptions].delete(:LabelDelivery)
            payload[:ShipmentRequest][:Shipment].delete(:ShipmentServiceOptions)
            payload[:ShipmentRequest][:Shipment].delete(:ShipmentDate)

          end

          payload[:ShipmentRequest][:Shipment][:Package] = shipment.packages.map do |package|
            GeneratePackageHash.call(package: package, package_flavor: 'labels')
          end

          payload[:ShipmentRequest][:LabelSpecification] = {
            LabelImageFormat: {
              Code: options.label_format
            },
            LabelStockSize: {
              Width: options.label_size[0].to_s, # "Valid value is 4."
              Height: options.label_size[1].to_s # "Only valid values are 6 or 8."
            }
          }
          # TODO needed?
          # This is the preferred way of identifying GIF image type to be generated. Required if /ShipmentRequest/LabelSpecificationLabelSpecification/LabelImageFormat/Code = Gif. Default to Mozilla/4.5 if this field is missing or has invalid value.
          # HTTPUserAgent: "Mozilla/4.5"

          payload.compact
        end

        def self.international?(shipment)
          shipment.origin.country != shipment.destination.country
        end

        def self.build_ddp_billing_info(options)
          billing_options = options.billing_options
          {
            Type: "02", # Duties and taxes
            BillThirdParty: {
              AccountNumber: billing_options.billing_account,
              # SuppressPrintInvoiceIndicator: " ", # https://developer.ups.com/api/reference/shipping/faq?loc=en_US, Duty & Taxes
              Address: {
                PostalCode: billing_options.billing_zip,
                CountryCode: billing_options.billing_country
              }
            }
          }
        end

        def self.international_forms(shipment, options)
          reason_for_export = options.return_service_code ? "RETURN" : options.reason_for_export
          invoice_date = options.invoice_date || Date.current
          result = {
            FormType: "01", # 01 is "Invoice"
            InvoiceDate: invoice_date.strftime("%Y%m%d"),
            ReasonForExport: reason_for_export,
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
            cost = reference_item.cost || Money.new(0, 'USD')
            # Get the options for this item
            item_options = all_item_options.detect { |o| o.item_id == reference_item.id } || LabelItemOptions.new(item_id: nil)

            product_hash = {
              # TODO "a maximum of 3 times" - what does this mean?
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
      end
    end
  end
end
