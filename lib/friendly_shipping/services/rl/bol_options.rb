# frozen_string_literal: true

require 'friendly_shipping/shipment_options'
require 'friendly_shipping/services/rl/bol_packages_serializer'

module FriendlyShipping
  module Services
    class RL
      class BOLOptions < ShipmentOptions
        attr_reader :pickup_time_window,
                    :pickup_instructions,
                    :declared_value,
                    :special_instructions,
                    :reference_numbers,
                    :additional_service_codes,
                    :generate_universal_pro,
                    :packages_serializer

        # @param [Range] pickup_time_window
        # @param [String] pickup_instructions
        # @param [Numeric] declared_value
        # @param [String] special_instructions
        # @param [Hash] reference_numbers
        # @param [Array<String>] additional_service_codes
        # @param [Boolean] generate_universal_pro
        # @param [Callable] packages_serializer A callable that takes packages
        #   and an options object to create an Array of item hashes per the R+L Carriers docs
        # @param [Array<Object>] **kwargs
        def initialize(
          pickup_time_window:,
          pickup_instructions: nil,
          declared_value: nil,
          special_instructions: nil,
          reference_numbers: {},
          additional_service_codes: [],
          packages_serializer: BOLPackagesSerializer,
          generate_universal_pro: false,
          **kwargs
        )
          @pickup_time_window = pickup_time_window
          @pickup_instructions = pickup_instructions
          @declared_value = declared_value
          @special_instructions = special_instructions
          @reference_numbers = reference_numbers
          @additional_service_codes = additional_service_codes
          @packages_serializer = packages_serializer
          @generate_universal_pro = generate_universal_pro
          validate_additional_service_codes!
          super(**kwargs.merge(package_options_class: PackageOptions))
        end

        ADDITIONAL_SERVICE_CODES = %w[
          OriginLiftgate
          DestinationLiftgate
          InsidePickup
          InsideDelivery
          LimitedAccessPickup
          LimitedAccessDelivery
          Freezable
          DeliveryAppointment
        ].freeze

        private

        # @raise [ArgumentError] invalid additional service codes
        # @return [nil]
        def validate_additional_service_codes!
          invalid_codes = (additional_service_codes - ADDITIONAL_SERVICE_CODES)
          return unless invalid_codes.any?

          raise ArgumentError, "Invalid additional service code(s): #{invalid_codes.join(',')}"
        end
      end
    end
  end
end
