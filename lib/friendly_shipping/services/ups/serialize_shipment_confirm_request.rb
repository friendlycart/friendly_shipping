# frozen_string_literal: true

require 'friendly_shipping/services/ups/serialize_shipment_address_snippet'
require 'friendly_shipping/services/ups/serialize_package_node'

module FriendlyShipping
  module Services
    class Ups
      class SerializeShipmentConfirmRequest
        class << self
          # Item options (only necessary for international shipping)
          # ShipTo CompanyName & AttentionName required for international shipping
          #
          # @option description [String] A description of the item for the intl. invoice
          # @option commodity_code [String] Commodity code for the item. See https://www.tariffnumber.com/
          # @option value [Money] Price of the item
          # @option unit_of_item_count [String] What kind of thing is one of this item? Example: Barrel, m3.
          #   See UPS docs for codes.
          #
          def call(
            shipment:,
            options:
          )
            xml_builder = Nokogiri::XML::Builder.new do |xml|
              xml.ShipmentConfirmRequest do
                xml.Request do
                  xml.RequestAction('ShipConfirm')
                  # Required element controls level of address validation.
                  xml.RequestOption(options.validate_address ? 'validate' : 'nonvalidate')
                  xml.SubVersion('1707')
                  # Optional element to identify transactions between client and server.
                  if options.customer_context
                    xml.TransactionReference do
                      xml.CustomerContext(options.customer_context)
                    end
                  end
                end

                xml.Shipment do
                  xml.Service do
                    xml.Code(options.shipping_method.service_code)
                  end

                  xml.ShipTo do
                    SerializeShipmentAddressSnippet.call(xml: xml, location: shipment.destination, international: international?(shipment))
                  end

                  # Required element. The company whose account is responsible for the label(s).
                  xml.Shipper do
                    SerializeShipmentAddressSnippet.call(xml: xml, location: options.shipper || shipment.origin)

                    xml.ShipperNumber(options.shipper_number)
                  end

                  if options.shipper || options.return_service_code
                    origin = options.return_service_code ? shipment.destination : shipment.origin
                    xml.ShipFrom do
                      SerializeShipmentAddressSnippet.call(xml: xml, location: origin)
                    end
                  end

                  if options.negotiated_rates
                    xml.RateInformation do
                      xml.NegotiatedRatesIndicator
                    end
                  end

                  # shipment.options.fetch(:reference_numbers, {}).each do |reference_code, reference_value|
                  #   xml.ReferenceNumber do
                  #     xml.Code(reference_code)
                  #     xml.Value(reference_value)
                  #   end
                  # end

                  if options.billing_options.prepay
                    xml.PaymentInformation do
                      xml.Prepaid do
                        build_billing_info_node(xml, options)
                      end
                    end
                  else
                    xml.ItemizedPaymentInformation do
                      xml.ShipmentCharge do
                        # Type '01' means 'Transportation'
                        # This node specifies who will be billed for transportation.
                        xml.Type('01')
                        build_billing_info_node(xml, options)
                      end
                      if international?(shipment) && options.terms_of_shipment_code == 'DDP'
                        # The shipper will cover duties and taxes
                        # Otherwise UPS will charge the receiver
                        xml.ShipmentCharge do
                          xml.Type('02') # Type '02' means 'Duties and Taxes'
                          build_billing_info_node(
                            xml,
                            options,
                            bill_to_consignee: true
                          )
                        end
                      end
                    end
                  end

                  if international?(shipment)
                    unless options.return_service_code
                      xml.SoldTo do
                        sold_to_location = options.sold_to || shipment.destination
                        SerializeShipmentAddressSnippet.call(xml: xml, location: sold_to_location)
                      end
                    end

                    if shipment.origin.country.code == 'US' && ['CA', 'PR'].include?(shipment.destination.country.code)
                      # Required for shipments from the US to Puerto Rico or Canada
                      # We'll assume USD as the origin country is the United States here.
                      xml.InvoiceLineTotal do
                        total_value = shipment.packages.inject(Money.new(0, 'USD')) do |shipment_sum, package|
                          shipment_sum + package.items.inject(Money.new(0, 'USD')) do |package_sum, item|
                            package_sum + (item.cost || Money.new(0, 'USD'))
                          end
                        end
                        xml.MonetaryValue(total_value.to_f)
                      end
                    end

                    contents_description = shipment.packages.flat_map do |package|
                      package.items.map(&:description)
                    end.compact.uniq.join(', ').slice(0, 50)

                    unless contents_description.empty?
                      xml.Description(contents_description)
                    end
                  end

                  if options.return_service_code
                    xml.ReturnService do
                      xml.Code(options.return_service_code)
                    end
                  end

                  xml.ShipmentServiceOptions do
                    xml.SaturdayDelivery if options.saturday_delivery
                    xml.UPScarbonneutralIndicator if options.carbon_neutral
                    if options.delivery_confirmation_code
                      xml.DeliveryConfirmation do
                        xml.DCISType(options.delivery_confirmation_code)
                      end
                    end

                    if international?(shipment)
                      build_international_forms(xml, shipment, options)
                    end
                  end

                  shipment.packages.each do |package|
                    package_options = options.options_for_package(package)
                    reference_numbers = allow_package_level_reference_numbers(shipment) ? package_options.reference_numbers : {}
                    delivery_confirmation_code = package_level_delivery_confirmation?(shipment) ? package_options.delivery_confirmation_code : nil
                    SerializePackageNode.call(
                      xml: xml,
                      package: package,
                      reference_numbers: reference_numbers,
                      delivery_confirmation_code: delivery_confirmation_code,
                      shipper_release: package_options.shipper_release
                    )
                  end
                end

                xml.LabelSpecification do
                  xml.LabelStockSize do
                    xml.Height(options.label_size[0])
                    xml.Width(options.label_size[1])
                  end

                  xml.LabelPrintMethod do
                    xml.Code(options.label_format)
                  end

                  # API requires these only if returning a GIF formated label
                  if options.label_format == 'GIF'
                    xml.HTTPUserAgent('Mozilla/4.5')
                    xml.LabelImageFormat(options.label_format) do
                      xml.Code(options.label_format)
                    end
                  end
                end
              end
            end
            xml_builder.to_xml
          end

          private

          # if the package is US -> US or PR -> PR the only type of reference numbers that are allowed are package-level
          # Otherwise the only type of reference numbers that are allowed are shipment-level
          def allow_package_level_reference_numbers(shipment)
            origin, destination = shipment.origin.country.code, shipment.destination.country.code
            [['US', 'US'], ['PR', 'PR']].include?([origin, destination])
          end

          # For certain origin/destination pairs, UPS allows each package in a shipment to have a specified
          # delivery_confirmation option
          # otherwise the delivery_confirmation option must be specified on the entire shipment.
          # See Appendix P of UPS Shipping Package XML Developers Guide for the rules on which the logic below is based.
          def package_level_delivery_confirmation?(shipment)
            origin, destination = shipment.origin.country.code, shipment.destination.country.code
            origin == destination || [['US', 'PR'], ['PR', 'US']].include?([origin, destination])
          end

          def build_billing_info_node(xml, options, bill_to_consignee: false)
            billing_options = options.billing_options
            if billing_options.bill_third_party || bill_to_consignee
              xml.BillThirdParty do
                node_type = bill_to_consignee ? :BillThirdPartyConsignee : :BillThirdPartyShipper
                xml.public_send(node_type) do
                  xml.AccountNumber(billing_options.billing_account)
                  xml.ThirdParty do
                    xml.Address do
                      xml.PostalCode(billing_options.billing_zip)
                      xml.CountryCode(billing_options.billing_country)
                    end
                  end
                end
              end
            else
              xml.BillShipper do
                xml.AccountNumber(options.shipper_number)
              end
            end
          end

          def build_international_forms(xml, shipment, options)
            return unless options.paperless_invoice

            reason_for_export = options.return_service_code ? "RETURN" : options.reason_for_export

            invoice_date = options.invoice_date || Date.current
            xml.InternationalForms do
              xml.FormType('01') # 01 is "Invoice"
              xml.InvoiceDate(invoice_date.strftime('%Y%m%d'))
              xml.ReasonForExport(reason_for_export)
              xml.CurrencyCode(options.billing_options.currency || 'USD')

              if options.terms_of_shipment_code
                xml.TermsOfShipment(options.terms_of_shipment_code)
              end
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
                # Get the options for this item
                item_options = all_item_options.detect { |o| o.item_id == reference_item.id } || LabelItemOptions.new(item_id: nil)

                xml.Product do
                  cost = reference_item.cost || Money.new(0, 'USD')
                  xml.Description(description&.slice(0, 35))
                  xml.CommodityCode(item_options.commodity_code)
                  xml.OriginCountryCode(item_options.country_of_origin || shipment.origin.country.code)
                  xml.Unit do
                    xml.Value(cost)
                    xml.Number(items.length)
                    xml.UnitOfMeasurement do
                      xml.Code(item_options.product_unit_of_measure_code)
                    end
                  end
                end
              end
            end
          end

          def international?(shipment)
            shipment.origin.country != shipment.destination.country
          end
        end
      end
    end
  end
end
