# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      EU_COUNTRIES = %w(
        AT BE BG CY CZ DE DK EE ES FI FR GB GR HR HU IE IT LT LU LV MT NL PO PT RO SE SI SK
      ).map { |country_code| Carmen::Country.coded(country_code) }

      class << self
        private

        def countries_by_code(code)
          all_countries = Carmen::Country.all
          covered_countries = EU_COUNTRIES + %w(US PR CA PL MX).map do |country_code|
            Carmen::Country.coded(country_code)
          end
          other_countries = Carmen::Country.all - covered_countries
          case code
          when 'EU' then EU_COUNTRIES
          when 'OTHER' then other_countries
          when 'ALL' then all_countries
          else
            [Carmen::Country.coded(code)]
          end
        end
      end

      SHIPPING_METHODS = [
        ['US', 'international', 'UPS Standard', '11'],
        ['US', 'international', 'UPS Worldwide Express®', '07'],
        ['US', 'international', 'UPS Worldwide Expedited®', '08'],
        ['US', 'international', 'UPS Worldwide Express Plus®', '54'],
        ['US', 'international', 'UPS Worldwide Saver', '65'],
        ['US', 'domestic', 'UPS 2nd Day Air®', '02'],
        ['US', 'domestic', 'UPS 2nd Day Air A.M.', '59'],
        ['US', 'domestic', 'UPS 3 Day Select®', '12'],
        ['US', 'domestic', 'UPS Ground', '03'],
        ['US', 'domestic', 'UPS Next Day Air®', '01'],
        ['US', 'domestic', 'UPS Next Day Air® Early', '14'],
        ['US', 'domestic', 'UPS Next Day Air Saver®', '13'],
        ['US', 'domestic', 'UPS SurePost Less than 1LB', '92'],
        ['US', 'domestic', 'UPS SurePost 1LB or greater', '93'],
        ['US', 'domestic', 'UPS SurePost BPM', '94'],
        ['US', 'domestic', 'UPS SurePost Media Mail', '95'],
        ['CA', 'domestic', 'UPS Expedited Canadian domestic shipments', '02'],
        ['CA', 'domestic', 'UPS Express Saver Canadian domestic shipments', '13'],
        ['CA', 'domestic', 'UPS 3 Day Select Shipments originating in Canada to CA and US 48', '12'],
        ['CA', 'international', 'UPS 3 Day Select Shipments originating in Canada to CA and US 48', '12'],
        ['CA', 'domestic', 'UPS Access Point Economy Canadian domestic shipments', '70'],
        ['CA', 'domestic', 'UPS Express Canadian domestic shipments', '01'],
        ['CA', 'domestic', 'UPS Express Early Canadian domestic shipments', '14'],
        ['CA', 'international', 'UPS Express Saver International shipments originating in Canada', '65'],
        ['CA', 'international', 'UPS Standard Shipments originating in Canada (Domestic and Int’l)', '11'],
        ['CA', 'domestic', 'UPS Standard Shipments originating in Canada (Domestic and Int’l)', '11'],
        ['CA', 'international', 'UPS Worldwide Expedited International shipments originating in Canada', '08'],
        ['CA', 'international', 'UPS Worldwide Express International shipments originating in Canada', '07'],
        ['CA', 'international', 'UPS Worldwide Express Plus International shipments originating in Canada', '54'],
        ['CA', 'international', 'UPS Express Early Shipments originating in Canada to CA and US 48', '54'],
        ['CA', 'domestic', 'UPS Express Early Shipments originating in Canada to CA and US 48', '54'],
        ['EU', 'domestic', 'UPS Access Point Economy Shipments within the European Union', '70'],
        ['EU', 'international', 'UPS Expedited Shipments originating in the European Union', '08'],
        ['EU', 'international', 'UPS Express Shipments originating in the European Union', '07'],
        ['EU', 'international', 'UPS Standard Shipments originating in the European Union', '11'],
        ['EU', 'international', 'UPS Worldwide Express Plus Shipments originating in the European Union', '54'],
        ['EU', 'international', 'UPS Worldwide Saver Shipments originating in the European Union', '65'],
        ['MX', 'domestic', 'UPS Access Point Economy Shipments within Mexico', '70'],
        ['MX', 'international', 'UPS Expedited Shipments originating in Mexico', '08'],
        ['MX', 'international', 'UPS Express Shipments originating in Mexico', '07'],
        ['MX', 'international', 'UPS Standard Shipments originating in Mexico', '11'],
        ['MX', 'international', 'UPS Worldwide Express Plus Shipments originating in Mexico', '54'],
        ['MX', 'international', 'UPS Worldwide Saver Shipments originating in Mexico', '65'],
        ['PL', 'domestic', 'UPS Access Point Economy Polish domestic shipments', '70'],
        ['PL', 'domestic', 'UPS Today Dedicated Courier Polish domestic shipments', '83'],
        ['PL', 'domestic', 'UPS Today Express Polish domestic shipments', '85'],
        ['PL', 'domestic', 'UPS Today Express Saver Polish domestic shipments', '86'],
        ['PL', 'domestic', 'UPS Today Standard Polish domestic shipments', '82'],
        ['PL', 'international', 'UPS Expedited Shipments originating in Poland', '08'],
        ['PL', 'international', 'UPS Express Shipments originating in Poland', '07'],
        ['PL', 'international', 'UPS Express Plus Shipments originating in Poland', '54'],
        ['PL', 'international', 'UPS Express Saver Shipments originating in Poland', '65'],
        ['PL', 'international', 'UPS Standard Shipments originating in Poland', '11'],
        ['PR', 'domestic', 'UPS 2nd Day Air', '02'],
        ['PR', 'domestic', 'UPS Ground', '03'],
        ['PR', 'domestic', 'UPS Next Day Air', '01'],
        ['PR', 'domestic', 'UPS Next Day Air Early', '14'],
        ['PR', 'international', 'UPS Worldwide Expedited', '08'],
        ['PR', 'international', 'UPS Worldwide Express', '07'],
        ['PR', 'international', 'UPS Worldwide Express Plus', '54'],
        ['PR', 'international', 'UPS Worldwide Saver', '65'],
        ['DE', 'domestic', 'UPS Express 12:00 German domestic shipments', '74'],
        ['OTHER', 'domestic', 'UPS Express', '07'],
        ['OTHER', 'domestic', 'UPS Standard', '11'],
        ['OTHER', 'international', 'UPS Worldwide Expedited', '08'],
        ['OTHER', 'international', 'UPS Worldwide Express Plus', '54'],
        ['OTHER', 'international', 'UPS Worldwide Saver', '65'],
        ['ALL', 'international', 'UPS Worldwide Express Freight', '96'],
        ['ALL', 'international', 'UPS Worldwide Express Freight Midday', '71']
      ].freeze.map do |origin_country_code, dom_or_intl, name, code|
        FriendlyShipping::ShippingMethod.new(
          name: name,
          service_code: code,
          domestic: dom_or_intl == 'domestic',
          international: dom_or_intl == 'international',
          origin_countries: countries_by_code(origin_country_code),
          multi_package: true
        ).freeze
      end
    end
  end
end
