# frozen_string_literal: true

require 'friendly_shipping/services/usps/parse_xml_response'
require 'friendly_shipping/services/usps/parse_package_rate'
require 'friendly_shipping/services/usps/choose_package_rate'

module FriendlyShipping
  module Services
    class Usps
      class ParseRateResponse
        class BoxNotFoundError < StandardError; end

        class << self
          # Parse a response from USPS' rating API
          #
          # @param [FriendlyShipping::Request] request The request that was used to obtain this Response
          # @param [FriendlyShipping::Response] response The response that USPS returned
          # @param [Physical::Shipment] shipment The shipment object we're trying to get results for
          # @return [Result<Array<FriendlyShipping::Rate>>] When successfully parsing, an array of rates in a Success Monad.
          def call(request:, response:, shipment:)
            # Filter out error responses and directly return a failure
            parsing_result = ParseXMLResponse.call(response.body, 'RateV4Response')
            parsing_result.fmap do |xml|
              # Get all the possible rates for each package
              rates_by_package = rates_from_response_node(xml, shipment)

              SHIPPING_METHODS.map do |shipping_method|
                # For every package ...
                matching_rates = rates_by_package.map do |package, rates|
                  # ... choose the rate that fits this package best.
                  ChoosePackageRate.call(shipping_method, package, rates)
                end.compact # Some shipping rates are not available for every shipping method.

                # in this case, go to the next shipping method.
                next if matching_rates.empty?

                # return one rate for all packages with the amount keys being the package IDs.
                FriendlyShipping::Rate.new(
                  amounts: matching_rates.map(&:amounts).reduce({}, :merge),
                  shipping_method: shipping_method,
                  data: matching_rates.first.data,
                  original_request: request,
                  original_response: response
                )
              end.compact
            end
          end

          private

          PACKAGE_NODE_XPATH = '//Package'
          SERVICE_NODE_NAME = 'Postage'

          # Iterate over all packages and parse the rates for each package
          #
          # @param [Nokogiri::XML::Node] xml The XML document containing packages and rates
          # @param [Physical::Shipment] shipment The shipment we're trying to get rates for
          #
          # @return [Hash<Physical::Package => Array<FriendlyShipping::Rate>>]
          def rates_from_response_node(xml, shipment)
            xml.xpath(PACKAGE_NODE_XPATH).each_with_object({}) do |package_node, result|
              package_id = package_node['ID']
              corresponding_package = shipment.packages.detect { |p| p.id == package_id }

              # There should always be a package in the original shipment that corresponds to the package ID
              # in the USPS response.
              raise BoxNotFoundError if corresponding_package.nil?

              result[corresponding_package] = package_node.xpath(SERVICE_NODE_NAME).map do |service_node|
                ParsePackageRate.call(service_node, corresponding_package)
              end
            end
          end
        end
      end
    end
  end
end
