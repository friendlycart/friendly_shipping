# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      # Represents billing-related options for obtaining shipment labels.
      # @option bill_third_party [Boolean] When truthy, bill an account other than the shipper's.
      #  Specified by billing_(account, zip and country)
      # @option bill_to_consignee [Boolean] If billing a third party, bill the consignee instead of the 3rd party shipper
      # @option prepay [Boolean] If truthy the shipper will be bill immediately. Otherwise the shipper is billed
      #   when the label is used. Default: false
      # @option sold_to_account_number [String] The account number to include in the SoldTo node of the request
      # @option sold_to_tax_id_number [String] The tax identification number to include in the SoldTo node of the request
      class LabelBillingOptions
        attr_reader :bill_third_party,
                    :bill_to_consignee,
                    :prepay,
                    :billing_account,
                    :billing_zip,
                    :billing_country,
                    :currency,
                    :sold_to_account_number,
                    :sold_to_tax_id_number

        def initialize(
          bill_third_party: false,
          bill_to_consignee: false,
          prepay: false,
          billing_account: nil,
          billing_zip: nil,
          billing_country: nil,
          currency: nil,
          sold_to_account_number: nil,
          sold_to_tax_id_number: nil
        )
          @bill_third_party = bill_third_party
          @bill_to_consignee = bill_to_consignee
          @prepay = prepay
          @billing_account = billing_account
          @billing_zip = billing_zip
          @billing_country = billing_country
          @currency = currency
          @sold_to_account_number = sold_to_account_number
          @sold_to_tax_id_number = sold_to_tax_id_number
        end
      end
    end
  end
end
