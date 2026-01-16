# frozen_string_literal: true

require "physical"
require "money"
require "dry/monads"
require "restclient"

# Explicitly configure the default rounding mode to avoid deprecation warnings
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN

require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect(
  "rl" => "RL",
  "parse_create_bol_response" => "ParseCreateBOLResponse",
  "parse_print_bol_response" => "ParsePrintBOLResponse",
  "serialize_create_bol_request" => "SerializeCreateBOLRequest",
  "bol_structures_serializer" => "BOLStructuresSerializer",
  "bol_packages_serializer" => "BOLPackagesSerializer",
  "bol_options" => "BOLOptions",
  "g2mint" => "G2Mint",
  "ship_engine_ltl" => "ShipEngineLTL",
  "tforce_freight" => "TForceFreight",
  "generate_create_bol_request_hash" => "GenerateCreateBOLRequestHash",
  "parse_xml_response" => "ParseXMLResponse",
  "usps_ship" => "USPSShip",
  "shipping_methods" => "SHIPPING_METHODS"
)
loader.setup

module FriendlyShipping
end
