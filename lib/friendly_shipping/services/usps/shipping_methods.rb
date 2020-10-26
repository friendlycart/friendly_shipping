# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      CONTAINERS = {
        variable: 'VARIABLE',
        large_flat_rate_box: 'LG FLAT RATE BOX',
        medium_flat_rate_box: 'MD FLAT RATE BOX',
        small_flat_rate_box: 'SM FLAT RATE BOX',
        regional_rate_box_a: 'REGIONALRATEBOXA',
        regional_rate_box_b: 'REGIONALRATEBOXB',
        flat_rate_envelope: 'FLAT RATE ENVELOPE',
        legal_flat_rate_envelope: 'LEGAL FLAT RATE ENVELOPE',
        padded_flat_rate_envelope: 'PADDED FLAT RATE ENVELOPE',
        gift_card_flat_rate_envelope: 'GIFT CARD FLAT RATE ENVELOPE',
        window_flat_rate_envelope: 'WINDOW FLAT RATE ENVELOPE',
        small_flat_rate_envelope: 'SM FLAT RATE ENVELOPE',
        cubic_soft_pack: 'CUBIC SOFT PACK',
        cubic_parcels: 'CUBIC PARCELS'
      }.freeze

      FIRST_CLASS_MAIL_TYPES = {
        letter: 'LETTER',
        flat: 'FLAT',
        parcel: 'PARCEL',
        post_card: 'POSTCARD',
        package_service: 'PACKAGE SERVICE',
        package_service_retail: 'PACKAGE SERVICE RETAIL'
      }.freeze

      SHIPPING_METHODS = [
        ['FIRST CLASS', 'First-Class'],
        ['PACKAGE SERVICES', 'Package Services'],
        ['PRIORITY', 'Priority Mail'],
        ['PRIORITY MAIL EXPRESS', 'Priority Mail Express'],
        ['STANDARD POST', 'Standard Post'],
        ['RETAIL GROUND', 'Retail Ground'],
        ['MEDIA MAIL', 'Media Mail'],
        ['LIBRARY MAIL', 'Library Mail'],
      ].map do |code, name|
        FriendlyShipping::ShippingMethod.new(
          origin_countries: [Carmen::Country.coded('US')],
          name: name,
          service_code: code,
          domestic: true,
          international: false
        )
      end.freeze
    end
  end
end
