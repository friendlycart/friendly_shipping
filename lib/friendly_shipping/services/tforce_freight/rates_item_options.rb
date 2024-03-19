# frozen_string_literal: true

require 'friendly_shipping/services/tforce_freight/item_options'

module FriendlyShipping
  module Services
    class TForceFreight
      # @deprecated use {FriendlyShipping::Services::TForceFreight::ItemOptions} instead
      RatesItemOptions = ItemOptions
    end
  end
end
