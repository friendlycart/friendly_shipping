# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializeShipmentAddressSnippet < SerializeAddressSnippet
        class << self
          private

          def residential_address_indicator(xml, location)
            # Shipment creation uses a different element to indicate residential addresses.
            # Rates use ResidentialAddressIndicator whereas shipments use ResidentialAddress.
            # Presence indicates residential address. Absence indicates commercial address.
            #
            xml.ResidentialAddress unless location.commercial?
          end
        end
      end
    end
  end
end
