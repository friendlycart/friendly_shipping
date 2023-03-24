# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializeAddressSnippet
        class << self
          def call(xml:, location:, international: false)
            if international
              name = (location.company_name || location.name)[0..34]
              attention_name = location.name
            elsif location.company_name # Is this a business address?
              name = location.company_name[0..34]
              attention_name = location.name
            else
              name = location.name
              attention_name = nil
            end

            # UPS wants a different main Name tag when it's the shipper
            if xml.parent.name == "Shipper"
              xml.Name(name)
            else
              xml.CompanyName(name)
            end

            if attention_name
              xml.AttentionName(attention_name)
            end

            xml.PhoneNumber(location.phone) if location.phone

            xml.Address do
              xml.AddressLine1(location.address1) if location.address1
              xml.AddressLine2(location.address2) if location.address2

              xml.City(location.city) if location.city
              xml.PostalCode(location.zip) if location.zip

              # StateProvinceCode required for negotiated rates but not otherwise, for some reason
              xml.StateProvinceCode(location.region.code) if location.region
              xml.CountryCode(location.country.code) if location.country
              residential_address_indicator(xml, location)
            end
          end

          private

          def residential_address_indicator(xml, location)
            # Quote residential rates by default. If UPS doesn't know if the address is residential or
            # commercial, it will quote a residential rate by default. Even with this flag being set,
            # if UPS knows the address is commercial it will often quote a commercial rate.
            #
            xml.ResidentialAddressIndicator unless location.commercial?
          end
        end
      end
    end
  end
end
