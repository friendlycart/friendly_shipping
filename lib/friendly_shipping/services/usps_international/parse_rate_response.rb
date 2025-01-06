# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UspsInternational
      class ParseRateResponse
        class BoxNotFoundError < StandardError; end

        class << self
          # Parse a response from USPS' international rating API
          #
          # @param [FriendlyShipping::Request] request The request that was used to obtain this Response
          # @param [FriendlyShipping::Response] response The response that USPS returned
          # @param [Physical::Shipment] shipment The shipment object we're trying to get results for
          # @param [FriendlyShipping::Services::UspsInternational::RateEstimateOptions] options The options we sent with this request
          # @return [Result<ApiResult<Array<FriendlyShipping::Rate>>>] When successfully parsing, an array of rates in a Success Monad.
          def call(request:, response:, shipment:, options:)
            # Filter out error responses and directly return a failure
            parsing_result = ParseXMLResponse.call(
              request: request,
              response: response,
              expected_root_tag: 'IntlRateV2Response'
            )
            parsing_result.fmap do |xml|
              # Get all the possible rates for each package
              rates_by_package = rates_from_response_node(xml, shipment, options)

              rates = SHIPPING_METHODS.map do |shipping_method|
                # For every package ...
                matching_rates = rates_by_package.map do |_package, package_rates|
                  # ... choose the rate that matches the shipping method for this package
                  package_rates.select { |r| r.shipping_method == shipping_method }.first
                end.compact # Some shipping rates are not available for every shipping method.

                # in this case, go to the next shipping method.
                next if matching_rates.empty?

                # return one rate for all packages with the amount keys being the package IDs.
                FriendlyShipping::Rate.new(
                  amounts: matching_rates.map(&:amounts).reduce({}, :merge),
                  shipping_method: shipping_method,
                  data: matching_rates.first.data
                )
              end.compact

              ApiResult.new(
                rates,
                original_request: request,
                original_response: response
              )
            end
          end

          private

          PACKAGE_NODE_XPATH = '//Package'
          SERVICE_NODE_NAME = 'Service'

          # Iterate over all packages and parse the rates for each package
          #
          # @param [Nokogiri::XML::Node] xml The XML document containing packages and rates
          # @param [Physical::Shipment] shipment The shipment we're trying to get rates for
          #
          # @return [Hash<Physical::Package => Array<FriendlyShipping::Rate>>]
          def rates_from_response_node(xml, shipment, options)
            xml.xpath(PACKAGE_NODE_XPATH).each_with_object({}) do |package_node, result|
              package_id = package_node['ID']
              corresponding_package = shipment.packages[package_id.to_i]
              package_options = options.options_for_package(corresponding_package)
              # There should always be a package in the original shipment that corresponds to the package ID
              # in the USPS response.
              raise BoxNotFoundError if corresponding_package.nil?

              result[corresponding_package] = package_node.xpath(SERVICE_NODE_NAME).map do |service_node|
                ParsePackageRate.call(service_node, corresponding_package, package_options)
              end
            end
          end
        end
      end
    end
  end
end
