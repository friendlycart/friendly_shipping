# frozen_string_literal: true

require "physical"
require "money"

# Explicitly configure the default rounding mode to avoid deprecation warnings
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN

require "friendly_shipping/version"
require "friendly_shipping/request"
require "friendly_shipping/response"
require "friendly_shipping/carrier"
require "friendly_shipping/shipping_method"
require "friendly_shipping/label"
require "friendly_shipping/rate"
require "friendly_shipping/api_result"
require "friendly_shipping/api_failure"

require "friendly_shipping/services/ship_engine"
require "friendly_shipping/services/ups"
require "friendly_shipping/services/ups_freight"
require "friendly_shipping/services/usps"

module FriendlyShipping
end
