# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class ParseMoneyHash
        def self.call(money_hash, key_name)
          return unless money_hash

          monetary_value = money_hash['MonetaryValue']&.to_d
          return if monetary_value.zero?

          currency_code = money_hash['CurrencyCode']
          currency = Money::Currency.new(currency_code)
          amount = Money.new(monetary_value * currency.subunit_to_unit, currency)

          surcharge_code = money_hash['Code']
          label = UPS_SURCHARGE_CODES[surcharge_code] || surcharge_code || key_name

          [label, amount]
        end

        UPS_SURCHARGE_CODES = {
          "100" => "ADDITIONAL HANDLING",
          "110" => "COD",
          "120" => "DELIVERY CONFIRMATION",
          "121" => "SHIP DELIVERY CONFIRMATION",
          "153" => "PKG EMAIL SHIP NOTIFICATION",
          "154" => "PKG EMAIL RETURN NOTIFICATION",
          "155" => "PKG EMAIL INBOUND RETURN NOTIFICATION",
          "156" => "PKG EMAIL QUANTUM VIEW SHIP NOTIFICATION",
          "157" => "PKG EMAIL QUANTUM VIEW EXCEPTION NOTIFICATION",
          "158" => "PKG EMAIL QUANTUM VIEW DELIVERY NOTIFICATION",
          "165" => "PKG FAX INBOUND RETURN NOTIFICATION",
          "166" => "PKG FAX QUANTUM VIEW SHIP NOTIFICATION",
          "171" => "SHIP EMAIL ERL NOTIFICATION",
          "173" => "SHIP EMAIL SHIP NOTIFICATION",
          "174" => "SHIP EMAIL RETURN NOTIFICATION",
          "175" => "SHIP EMAIL INBOUND RETURN NOTIFICATION",
          "176" => "SHIP EMAIL QUANTUM VIEW SHIP NOTIFICATION",
          "177" => "SHIP EMAIL QUANTUM VIEW EXCEPTION NOTIFICATION",
          "178" => "SHIP EMAIL QUANTUM VIEW DELIVERY NOTIFICATION",
          "179" => "SHIP EMAIL QUANTUM VIEW NOTIFY",
          "187" => "SHIP UPS ACCESS POINT NOTIFICATION",
          "188" => "SHIP EEI FILING NOTIFICATION",
          "189" => "SHIP UAP SHIPPER NOTIFICATION",
          "190" => "EXTENDED AREA",
          "200" => "DRY ICE",
          "220" => "HOLD FOR PICKUP",
          "240" => "ORIGIN CERTIFICATE",
          "250" => "PRINT RETURN LABEL",
          "258" => "EXPORT LICENSE VERIFICATION",
          "260" => "PRINT N MAIL",
          "270" => "RESIDENTIAL ADDRESS",
          "280" => "RETURN SERVICE 1ATTEMPT",
          "290" => "RETURN SERVICE 3ATTEMPT",
          "300" => "SATURDAY DELIVERY",
          "310" => "SATURDAY PICKUP",
          "330" => "PKG VERBAL CONFIRMATION",
          "350" => "ELECTRONIC RETURN LABEL",
          "372" => "QUANTUM VIEW NOTIFY DELIVERY",
          "374" => "UPS PREPARED SED FORM",
          "375" => "FUEL SURCHARGE",
          "376" => "DELIVERY AREA",
          "377" => "LARGE PACKAGE",
          "378" => "SHIPPER PAYS DUTY TAX",
          "379" => "SHIPPER PAYS DUTY TAX UNPAID",
          "400" => "INSURANCE",
          "401" => "SHIP ADDITIONAL HANDLING",
          "402" => "SHIPPER RELEASE",
          "403" => "CHECK TO SHIPPER",
          "404" => "UPS PROACTIVE RESPONSE",
          "405" => "GERMAN PICKUP",
          "406" => "GERMAN ROAD TAX",
          "407" => "EXTENDED AREA PICKUP",
          "410" => "RETURN OF DOCUMENT",
          "430" => "PEAK SEASON",
          "431" => "LARGE PACKAGE SEASONAL SURCHARGE",
          "432" => "ADDITIONAL HANDLING SEASONAL SURCHARGE",
          "440" => "SHIP LARGE PACKAGE",
          "441" => "CARBON NEUTRAL",
          "442" => "PKG QV IN TRANSIT NOTIFICATION",
          "443" => "SHIP QV IN TRANSIT NOTIFICATION",
          "444" => "IMPORT CONTROL",
          "445" => "COMMERCIAL INVOICE REMOVAL",
          "446" => "IMPORT CONTROL ELECTRONIC LABEL",
          "447" => "IMPORT CONTROL PRINT LABEL",
          "448" => "IMPORT CONTROL PRINT AND MAIL LABEL",
          "449" => "IMPORT CONTROL ONE PICK UP ATTEMPT LABEL",
          "450" => "IMPORT CONTROL THREE PICK UP ATTEMPT LABEL",
          "452" => "REFRIGERATION",
          "454" => "PAC 1A BOX1",
          "455" => "PAC 3A BOX1",
          "456" => "PAC 1A BOX2",
          "457" => "PAC 3A BOX2",
          "458" => "PAC 1A BOX3",
          "459" => "PAC 3A BOX3",
          "460" => "PAC 1A BOX4",
          "461" => "PAC 3A BOX4",
          "462" => "PAC 1A BOX5",
          "463" => "PAC 3A BOX5",
          "464" => "EXCHANGE PRINT RETURN LABEL",
          "465" => "EXCHANGE FORWARD",
          "466" => "SHIP PREALERT NOTIFICATION",
          "470" => "COMMITTED DELIVERY WINDOW",
          "480" => "SECURITY SURCHARGE",
          "492" => "CUSTOMER TRANSACTION FEE",
          "495" => "EXTENDED AREA SURCHARGE",
          "500" => "SHIPMENT COD",
          "510" => "LIFT GATE FOR PICKUP",
          "511" => "LIFT GATE FOR DELIVERY",
          "512" => "DROP OFF AT UPS FACILITY",
          "515" => "UPS PREMIUM CARE",
          "520" => "OVERSIZE PALLET",
          "530" => "FREIGHT DELIVERY SURCHARGE",
          "531" => "FREIGHT PICKUP SURCHARGE",
          "540" => "DIRECT TO RETAIL",
          "541" => "DIRECT DELIVERY ONLY",
          "542" => "DELIVER TO ADDRESSEE ONLY",
          "543" => "DIRECT TO RETAIL COD",
          "544" => "RETAIL ACCESS POINT545 SHIPPING TICKET NOTIFICATION",
          "546" => "ELECTRONIC PACKAGE RELEASE AUTHENTICATION",
          "547" => "PAY AT STORE"
        }.freeze
        private_constant :UPS_SURCHARGE_CODES
      end
    end
  end
end
