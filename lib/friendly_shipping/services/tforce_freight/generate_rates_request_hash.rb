# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Generates a rates request hash for JSON serialization.
      class GenerateRatesRequestHash
        class << self
          # @param shipment [Physical::Shipment] the shipment for which we want to get rates
          # @param options [RatesOptions] options for obtaining rates for this shipment
          # @return [Hash] rates request hash
          def call(shipment:, options:)
            {
              requestOptions: request_options(options),
              shipFrom: GenerateLocationHash.call(location: shipment.origin),
              shipTo: GenerateLocationHash.call(location: shipment.destination),
              payment: payment(options),
              serviceOptions: service_options(options),
              commodities: options.commodity_information_generator.call(shipment: shipment, options: options)
            }
          end

          private

          # @param options [RatesOptions]
          # @return [Hash]
          def request_options(options)
            {
              serviceCode: options.shipping_method.service_code,
              pickupDate: options.pickup_date.strftime('%Y-%m-%d'),
              type: options.type_code,
              densityEligible: options.density_eligible,
              gfpOptions: {
                accessorialRate: options.accessorial_rate,
              },
              timeInTransit: options.time_in_transit,
              quoteNumber: options.quote_number,
              customerContext: options.customer_context
            }.compact
          end

          # @param options [RatesOptions]
          # @return [Hash]
          def payment(options)
            {
              payer: GenerateLocationHash.call(location: options.billing_address),
              billingCode: options.billing_code
            }
          end

          # @param options [RatesOptions]
          # @return [Hash]
          def service_options(options)
            {
              pickup: options.pickup_options,
              delivery: options.delivery_options
            }
          end
        end
      end
    end
  end
end
