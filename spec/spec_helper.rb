# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'pry'
require "bundler/setup"
require "friendly_shipping"
require "vcr"
require "dotenv"

require "factory_bot"
require "physical/test_support"
FactoryBot.definition_file_paths.concat(Physical::TestSupport.factory_paths)
FactoryBot.reload

Dotenv.load(".env", ".env.test")

Money.locale_backend = nil

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.filter_sensitive_data('%SHIPENGINE_API_KEY%') { ENV['SHIPENGINE_API_KEY'] }
  c.filter_sensitive_data('%SHIPENGINE_CARRIER_ID%') { ENV['SHIPENGINE_CARRIER_ID'] }
  c.filter_sensitive_data('%SHIPENGINE_LTL_CARRIER_ID%') { ENV['SHIPENGINE_LTL_CARRIER_ID'] }
  c.filter_sensitive_data('%SHIPENGINE_LTL_CARRIER_SCAC%') { ENV['SHIPENGINE_LTL_CARRIER_SCAC'] }
  c.filter_sensitive_data('%UPS_LOGIN%') { ENV['UPS_LOGIN'] }
  c.filter_sensitive_data('%UPS_KEY%') { ENV['UPS_KEY'] }
  c.filter_sensitive_data('%UPS_PASSWORD%') { ENV['UPS_PASSWORD'] }
  c.filter_sensitive_data('%UPS_SHIPPER_NUMBER%') { ENV['UPS_SHIPPER_NUMBER'] }
  c.filter_sensitive_data('%USPS_LOGIN%') { ENV['USPS_LOGIN'] }

  # Matches the Content-Type request header
  c.register_request_matcher :content_type do |r1, r2|
    r1.headers['Content-Type'] == r2.headers['Content-Type']
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def gem_root
  spec = Gem::Specification.find_by_name("friendly_shipping")
  spec.gem_dir
end
