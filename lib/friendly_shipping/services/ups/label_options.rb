# frozen_string_literal: true

require 'friendly_shipping/services/ups/label_package_options'
require 'friendly_shipping/services/ups/label_billing_options'

module FriendlyShipping
  module Services
    # Option container for a generating UPS labels for a shipment
    #
    # Required:
    #
    # @param shipping_method [FriendlyShipping::ShippingMethod] The shipping method to use. We only need the
    #   service_code to be set.
    # @param shipper_number [String] account number for the shipper
    #
    # Optional:
    #
    # @param shipper [Physical::Location] The company sending the shipment. Defaults to the shipment's origin.
    # @param customer_context [String ] Optional element to identify transactions between client and server
    # @param validate_address [Boolean] Validate the city field with ZIP code and state. If false, only ZIP code
    #   and state are validated. Default: true
    # @param negotiated_rates [Boolean] if truthy negotiated rates will be requested from ups. Only valid if
    #   shipper account has negotiated rates. Default: false
    # @option sold_to [Physical::Location] The person or company who imports and pays any duties due on the
    #   current shipment. Default: The shipment's destination
    # @option saturday_delivery [Boolean] should we request Saturday delivery?. Default: false
    # @option label_format [String] GIF, EPL, ZPL, STARPL and SPL
    # @option label_size [Array<Integer>] Dimensions of the label. Default: [4, 6]
    # @option delivery_confirmation [Symbol] Can be set to any key from SHIPMENT_DELIVERY_CONFIRMATION_CODES.
    #   Only possible for international shipments that are not between the US and Puerto Rico.
    # @option carbon_neutral [Boolean] Ship with UPS' carbon neutral program
    # @option return_service_code [Symbol] If present, marks this a return label. The kind
    #   of return label is specified by the symbol, one of the keys in RETURN_SERVICE_CODES. Default: nil
    #
    # Shipment options for international shipping:
    #
    # @option paperless_invoice [Boolean] set to truthy if using paperless invoice to ship internationally. Default false
    # @option terms_of_shipment [Symbol] used with paperless invoice to specify who pays duties and taxes.
    #   See TERMS_OF_SHIPMENT constant for possible options.
    # @option reason_for_export [String] A reason to export the current shipment. Possible values: 'SALE', 'GIFT', 'SAMPLE',
    #   'RETURN', 'REPAIR', 'INTERCOMPANYDATA', Any other reason. Default: 'SALE'.
    # @option invoice_date [Date] The invoice date for the shipment
    #
    class Ups
      class LabelOptions < FriendlyShipping::ShipmentOptions
        SHIPMENT_DELIVERY_CONFIRMATION_CODES = {
          delivery_confirmation_signature_required: 1,
          delivery_confirmation_adult_signature_required: 2
        }.freeze

        TERMS_OF_SHIPMENT_CODES = {
          cost_and_freight: 'CFR',
          cost_insurance_and_freight: 'CIF',
          carriage_and_insurance_paid: 'CIP',
          carriage_paid_to: 'CPT',
          delivered_at_frontier: 'DAF',
          delivery_duty_paid: 'DDP',
          delivery_duty_unpaid: 'DDU',
          delivered_ex_quay: 'DEQ',
          delivered_ex_ship: 'DES',
          ex_works: 'EXW',
          free_alongside_ship: 'FAS',
          free_carrier: 'FCA',
          free_on_board: 'FOB'
        }.freeze

        RETURN_SERVICE_CODES = {
          ups_print_and_mail: 2, # UPS Print and Mail (PNM)
          ups_return_1_attempt: 3, # UPS Return Service 1-Attempt
          ups_return_3_attempt: 5, # UPS Return Service 3-Attempt (RS3)
          ups_electronic_return_label: 8, # UPS Electronic Return Label (ERL)
          ups_print_return_label: 9, # UPS Print Return Label (PRL)
          ups_exchange_print_return: 10, # UPS Exchange Print Return Label
          ups_pack_collect_1_attemt_box_1: 11, # UPS Pack & Collect Service 1-Attempt Box 1
          ups_pack_collect_1_attemt_box_2: 12, # UPS Pack & Collect Service 1-Attempt Box 2
          ups_pack_collect_1_attemt_box_3: 13, # UPS Pack & Collect Service 1-Attempt Box 3
          ups_pack_collect_1_attemt_box_4: 14, # UPS Pack & Collect Service 1-Attempt Box 4
          ups_pack_collect_1_attemt_box_5: 15, # UPS Pack & Collect Service 1-Attempt Box 5
          ups_pack_collect_3_attemt_box_1: 16, # UPS Pack & Collect Service 1-Attempt Box 1
          ups_pack_collect_3_attemt_box_2: 17, # UPS Pack & Collect Service 1-Attempt Box 2
          ups_pack_collect_3_attemt_box_3: 18, # UPS Pack & Collect Service 1-Attempt Box 3
          ups_pack_collect_3_attemt_box_4: 19, # UPS Pack & Collect Service 1-Attempt Box 4
          ups_pack_collect_3_attemt_box_5: 20 # UPS Pack & Collect Service 1-Attempt Box 5
        }.freeze

        attr_reader :shipping_method,
                    :shipper_number,
                    :shipper,
                    :customer_context,
                    :validate_address,
                    :negotiated_rates,
                    :billing_options,
                    :sold_to,
                    :saturday_delivery,
                    :label_format,
                    :label_size,
                    :carbon_neutral,
                    :paperless_invoice,
                    :reason_for_export,
                    :invoice_date

        def initialize(
          shipping_method:,
          shipper_number:,
          shipper: nil,
          customer_context: nil,
          validate_address: true,
          negotiated_rates: false,
          billing_options: LabelBillingOptions.new,
          sold_to: nil,
          saturday_delivery: false,
          label_format: 'GIF',
          label_size: [4, 6],
          delivery_confirmation: nil,
          carbon_neutral: true,
          return_service: nil,
          paperless_invoice: false,
          terms_of_shipment: nil,
          reason_for_export: nil,
          invoice_date: nil,
          package_options_class: LabelPackageOptions,
          **kwargs
        )
          @shipping_method = shipping_method
          @shipper_number = shipper_number
          @shipper = shipper
          @customer_context = customer_context
          @validate_address = validate_address
          @negotiated_rates = negotiated_rates
          @billing_options = billing_options
          @sold_to = sold_to
          @saturday_delivery = saturday_delivery
          @label_format = label_format
          @label_size = label_size
          @delivery_confirmation = delivery_confirmation
          @carbon_neutral = carbon_neutral
          @return_service = return_service
          @paperless_invoice = paperless_invoice
          @terms_of_shipment = terms_of_shipment
          @reason_for_export = reason_for_export
          @invoice_date = invoice_date
          super kwargs.merge(package_options_class: package_options_class)
        end

        def delivery_confirmation_code
          SHIPMENT_DELIVERY_CONFIRMATION_CODES[delivery_confirmation]
        end

        def terms_of_shipment_code
          TERMS_OF_SHIPMENT_CODES[terms_of_shipment]
        end

        def return_service_code
          RETURN_SERVICE_CODES[return_service]
        end

        private

        attr_reader :terms_of_shipment,
                    :return_service,
                    :delivery_confirmation
      end
    end
  end
end
