# frozen_string_literal: true

module FriendlyShipping
  module Services
    class TForceFreight
      # Options for creating a pickup.
      class PickupOptions < FriendlyShipping::ShipmentOptions
        # Maps friendly names to service options.
        SERVICE_OPTIONS = {
          inside: "INPU",
          liftgate: "LIFO",
          freezable: "PFFF",
          residential: "RESP",
          extreme_length: "EXLT",
          trade_show: "TRPU"
        }.freeze

        # @return [Time] date/time of pickup
        attr_reader :pickup_at

        # @return [Range] time window for pickup
        attr_reader :pickup_time_window

        # @return [Array<String>] shipment pickup service options (see {SERVICE_OPTIONS})
        attr_reader :service_options

        # @return [String] instructions for pickup
        attr_reader :pickup_instructions

        # @return [String] instructions for handling
        attr_reader :handling_instructions

        # @return [String] instructions for delivery
        attr_reader :delivery_instructions

        # @param pickup_at [Time] date/time of pickup (defaults to now)
        # @param pickup_time_window [Range] time window for pickup (defaults to start/end of today)
        # @param service_options [Array<String>] shipment pickup service options (see {SERVICE_OPTIONS})
        # @param pickup_instructions [String] instructions for pickup
        # @param handling_instructions [String] instructions for handling
        # @param delivery_instructions [String] instructions for delivery
        # @param kwargs [Hash]
        # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment
        # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
        def initialize(
          pickup_at: Time.now,
          pickup_time_window: Time.now.beginning_of_day..Time.now.end_of_day,
          service_options: [],
          pickup_instructions: nil,
          handling_instructions: nil,
          delivery_instructions: nil,
          **kwargs
        )
          @pickup_at = pickup_at
          @pickup_time_window = pickup_time_window
          @service_options = service_options
          @pickup_instructions = pickup_instructions
          @handling_instructions = handling_instructions
          @delivery_instructions = delivery_instructions

          validate_service_options!

          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end

        private

        # Raises an exception if the service options passed into the initializer
        # don't correspond to valid codes from {SERVICE_OPTIONS}.
        #
        # @raise [ArgumentError] invalid service options
        # @return [nil]
        def validate_service_options!
          invalid_options = (service_options - SERVICE_OPTIONS.values)
          return unless invalid_options.any?

          raise ArgumentError, "Invalid service option(s): #{invalid_options.join(', ')}"
        end
      end
    end
  end
end
