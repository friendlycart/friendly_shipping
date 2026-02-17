# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Options for a Reconex CreateLoad request.
      class LoadOptions < FriendlyShipping::ShipmentOptions
        # @return [Integer] the account ID
        attr_reader :account_id

        # @return [String] the SCAC code for the carrier to book
        attr_reader :scac

        # @return [Boolean] whether to rate the load
        attr_reader :rate

        # @return [Boolean] whether to request a PRO number
        attr_reader :pro_number_requested

        # @return [Boolean] whether to dispatch the load
        attr_reader :dispatch

        # @return [String, nil] email address for error notifications
        attr_reader :error_email

        # @return [String, nil] the PO number
        attr_reader :po_number

        # @return [String, nil] the custom ID
        attr_reader :custom_id

        # @return [String, nil] the customer billing
        attr_reader :customer_billing

        # @return [Physical::Location] the billing location
        attr_reader :billing_location

        # @return [String] the origin dock type
        attr_reader :dock_type

        # @return [String] the destination dock type
        attr_reader :destination_dock_type

        # @return [String, nil] notes for origin location
        attr_reader :origin_notes

        # @return [Time, nil] origin dock open time
        attr_reader :origin_dock_open

        # @return [Time, nil] origin dock close time
        attr_reader :origin_dock_close

        # @return [Boolean] whether origin requires appointment
        attr_reader :origin_appointment

        # @return [Time, nil] freight ready time at origin
        attr_reader :origin_freight_ready_time

        # @return [String, nil] notes for destination location
        attr_reader :destination_notes

        # @return [Time, nil] destination dock open time
        attr_reader :destination_dock_open

        # @return [Time, nil] destination dock close time
        attr_reader :destination_dock_close

        # @return [Boolean] whether destination requires appointment
        attr_reader :destination_appointment

        # @return [Hash] boolean flags for accessorial services
        attr_reader :accessorials

        # @return [Time, nil] the pickup date
        attr_reader :pickup_date

        # @return [Time, nil] the must-arrive-by date
        attr_reader :must_arrive_by_date

        # @return [String, nil] special instructions
        attr_reader :special_instructions

        # @return [Integer] shipping quantity
        attr_reader :shipping_quantity

        # @return [String, nil] load equipment type
        attr_reader :load_equipment_type

        # @return [String, nil] shipping units
        attr_reader :shipping_units

        # @return [Boolean] whether all items are stackable
        attr_reader :all_stackable

        # @return [String, nil] load notes
        attr_reader :load_notes

        # @return [Boolean] whether ASN is needed
        attr_reader :asn_needed

        def initialize(
          account_id:,
          scac:,
          rate: false,
          pro_number_requested: false,
          dispatch: false,
          error_email: nil,
          po_number: nil,
          custom_id: nil,
          customer_billing: nil,
          billing_location: nil,
          dock_type: "BusinessWithDock",
          destination_dock_type: nil,
          origin_notes: nil,
          origin_dock_open: nil,
          origin_dock_close: nil,
          origin_appointment: false,
          origin_freight_ready_time: nil,
          destination_notes: nil,
          destination_dock_open: nil,
          destination_dock_close: nil,
          destination_appointment: false,
          accessorials: {},
          pickup_date: nil,
          must_arrive_by_date: nil,
          special_instructions: nil,
          shipping_quantity: 1,
          load_equipment_type: nil,
          shipping_units: nil,
          all_stackable: false,
          load_notes: nil,
          asn_needed: false,
          structure_options: [],
          structure_options_class: StructureOptions,
          **kwargs
        )
          @account_id = account_id
          @scac = scac
          @rate = rate
          @pro_number_requested = pro_number_requested
          @dispatch = dispatch
          @error_email = error_email
          @po_number = po_number
          @custom_id = custom_id
          @customer_billing = customer_billing
          @billing_location = billing_location
          @dock_type = dock_type
          @destination_dock_type = destination_dock_type || dock_type
          @origin_notes = origin_notes
          @origin_dock_open = origin_dock_open
          @origin_dock_close = origin_dock_close
          @origin_appointment = origin_appointment
          @origin_freight_ready_time = origin_freight_ready_time
          @destination_notes = destination_notes
          @destination_dock_open = destination_dock_open
          @destination_dock_close = destination_dock_close
          @destination_appointment = destination_appointment
          @accessorials = accessorials
          @pickup_date = pickup_date
          @must_arrive_by_date = must_arrive_by_date
          @special_instructions = special_instructions
          @shipping_quantity = shipping_quantity
          @load_equipment_type = load_equipment_type
          @shipping_units = shipping_units
          @all_stackable = all_stackable
          @load_notes = load_notes
          @asn_needed = asn_needed
          @structure_options = structure_options
          @structure_options_class = structure_options_class
          validate_account_id!
          validate_scac!
          validate_dock_type!
          validate_accessorials!
          super(**kwargs.reverse_merge(package_options_class: PackageOptions))
        end

        # @param structure [#id] the structure for which to get options
        # @return [StructureOptions]
        def options_for_structure(structure)
          structure_options.detect do |structure_option|
            structure_option.structure_id == structure.id
          end || structure_options_class.new(structure_id: nil)
        end

        private

        # @return [Array<StructureOptions>]
        attr_reader :structure_options

        # @return [Class]
        attr_reader :structure_options_class

        # @raise [ArgumentError] missing account_id
        def validate_account_id!
          raise ArgumentError, "account_id is required" if account_id.nil?
        end

        # @raise [ArgumentError] missing scac
        def validate_scac!
          raise ArgumentError, "scac is required" if scac.nil? || scac.empty?
        end

        # @raise [ArgumentError] invalid dock type
        def validate_dock_type!
          [dock_type, destination_dock_type].each do |type|
            raise ArgumentError, "Invalid dock type: #{type}" unless QuoteOptions::DOCK_TYPES.include?(type)
          end
        end

        # @raise [ArgumentError] invalid accessorial keys
        def validate_accessorials!
          invalid_keys = accessorials.keys.map(&:to_sym) - QuoteOptions::ACCESSORIALS
          return if invalid_keys.empty?

          raise ArgumentError, "Invalid accessorial(s): #{invalid_keys.join(', ')}"
        end
      end
    end
  end
end
