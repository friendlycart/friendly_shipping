# frozen_string_literal: true

require 'friendly_shipping/services/usps_international/rate_estimate_options'

module FriendlyShipping
  module Services
    class UspsInternational
      include Dry::Monads[:result]

      CONTAINERS = {
        rectanglular: 'RECTANGULAR',
        roll: 'ROLL',
        variable: 'VARIABLE'
      }

      MAIL_TYPES = {
        all: 'ALL',
        airmail: 'AIRMAIL MBAG',
        envelope: 'ENVELOPE',
        flat_rate: 'FLATRATE',
        letter: 'LETTER',
        large_envelope: 'LARGEENVELOPE',
        package: 'PACKAGE',
        post_cards: 'POSTCARDS'
      }
    end
  end
end
