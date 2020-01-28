# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Usps
      CONTAINERS = {
        variable: 'VARIABLE',
        rectangular: 'RECTANGULAR',
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
        cubic_parcels: 'CUBIC_PARCELS'
      }.freeze

      FIRST_CLASS_MAIL_TYPES = {
        letter: 'LETTER',
        flat: 'FLAT',
        parcel: 'PARCEL',
        post_card: 'POSTCARD',
        package_service: 'PACKAGE SERVICE'
      }.freeze

      SHIPPING_METHODS = [
        'First-Class',
        'Package Services',
        'Priority',
        'Priority Mail Express',
        'Standard Post',
        'Retail Ground',
        'Media Mail',
        'Library Mail',
      ].map do |shipping_method_name|
        FriendlyShipping::ShippingMethod.new(
          origin_countries: [Carmen::Country.coded('US')],
          name: shipping_method_name,
          service_code: shipping_method_name.tr('-', ' ').upcase,
          domestic: true,
          international: false
        )
      end.freeze
    end
  end
end
