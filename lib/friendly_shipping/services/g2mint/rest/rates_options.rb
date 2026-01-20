# frozen_string_literal: true

module FriendlyShipping
  module Services
    class G2Mint
      module REST
        # Options for getting rates for a shipment.
        class RatesOptions < ShipmentOptions
          # @return [String] unique request identifier
          attr_reader :request_id

          # @return [String] account ID
          attr_reader :account_id

          # @return [String] owner tenant ID
          attr_reader :owner_tenant

          # @return [Physical::Location] bill to location
          attr_reader :bill_to_location

          # @return [String] bill to location name
          attr_reader :bill_to_location_name

          # @return [String] bill to location ID
          attr_reader :bill_to_location_id

          # @return [Hash] bill to contact information (firstName, lastName, phoneNumber, email)
          attr_reader :bill_to_contact

          # @return [Integer] distance of shipment
          attr_reader :distance

          # @return [String] direction of shipment (OUTBOUND, INBOUND)
          attr_reader :direction

          # @return [String] freight terms (THIRD_PARTY, PREPAID, COLLECT, etc.)
          attr_reader :freight_terms

          # @return [Array<String>] accessorial service codes
          attr_reader :accessorials

          # @return [Array<String>] transportation modes
          attr_reader :transportation_modes

          # @return [Date] pickup date
          attr_reader :pickup_date

          # @return [Hash] pickup time window (start and end times)
          attr_reader :pickup_time_window

          # @return [Hash] pickup contact information (firstName, lastName, phoneNumber, email)
          attr_reader :pickup_contact

          # @return [String] pickup note
          attr_reader :pickup_note

          # @return [Hash] delivery time window (start and end times)
          attr_reader :delivery_time_window

          # @return [Hash] delivery contact information (firstName, lastName, phoneNumber, email)
          attr_reader :delivery_contact

          # @return [String] delivery note
          attr_reader :delivery_note

          # @return [Callable] a callable that generates commodity information
          attr_reader :commodity_information_generator

          # @return [Callable] a callable that generates handling unit information
          attr_reader :handling_unit_generator

          # @return [Callable] a callable that generates packaging unit information
          attr_reader :packaging_unit_generator

          # @param request_id [String] unique request identifier (defaults to a UUID)
          # @param account_id [String] G2Mint account ID (required)
          # @param owner_tenant [String] G2Mint owner tenant ID (required)
          # @param bill_to_location [Physical::Location] bill to location (required)
          # @param bill_to_location_name [String] bill to location name (optional)
          # @param bill_to_location_id [String] bill to location ID (optional)
          # @param bill_to_contact [Hash] bill to contact information (required)
          # @param distance [String] distance of shipment
          # @param direction [String] direction of shipment (defaults to "OUTBOUND")
          # @param freight_terms [String] freight terms (optional)
          # @param accessorials [Array<String>] accessorial service codes (defaults to [])
          # @param transportation_modes [Array<String>] transportation modes (defaults to [])
          # @param pickup_date [Date] pickup date (defaults to today)
          # @param pickup_time_window [Hash] pickup time window with :start and :end (optional)
          # @param pickup_contact [Hash] pickup contact information (optional)
          # @param pickup_note [String] pickup note (optional)
          # @param delivery_time_window [Hash] delivery time window with :start and :end (optional)
          # @param delivery_contact [Hash] delivery contact information (optional)
          # @param delivery_note [String] delivery note (optional)
          # @param commodity_information_generator [Callable] callable to generate commodity information
          # @param handling_unit_generator [Callable] callable to generate handling unit information
          # @param packaging_unit_generator [Callable] callable to generate packaging unit information
          # @param structure_options [Array<StructureOptions>] options for structures in this shipment
          # @param structure_options_class [Class<StructureOptions>] the class to use for structure options when none are provided
          # @param kwargs [Hash]
          # @option kwargs [Array<PackageOptions>] :package_options the options for packages in this shipment
          # @option kwargs [Class] :package_options_class the class to use for package options when none are provided
          def initialize(
            account_id:,
            owner_tenant:,
            bill_to_location:,
            bill_to_contact:,
            request_id: SecureRandom.uuid,
            bill_to_location_name: nil,
            bill_to_location_id: nil,
            distance: nil,
            direction: "OUTBOUND",
            freight_terms: nil,
            accessorials: [],
            transportation_modes: [],
            pickup_date: Date.today,
            pickup_time_window: nil,
            pickup_contact: nil,
            pickup_note: nil,
            delivery_time_window: nil,
            delivery_contact: nil,
            delivery_note: nil,
            commodity_information_generator: GenerateCommodityInformation,
            handling_unit_generator: GenerateHandlingUnits,
            packaging_unit_generator: GeneratePackagingUnits,
            structure_options: [],
            structure_options_class: StructureOptions,
            **kwargs
          )
            @account_id = account_id
            @owner_tenant = owner_tenant
            @bill_to_location = bill_to_location
            @bill_to_contact = bill_to_contact
            @request_id = request_id
            @bill_to_location_name = bill_to_location_name
            @bill_to_location_id = bill_to_location_id
            @distance = distance
            @direction = direction
            @freight_terms = freight_terms
            @accessorials = accessorials
            @transportation_modes = transportation_modes
            @pickup_date = pickup_date
            @pickup_time_window = pickup_time_window
            @pickup_contact = pickup_contact
            @pickup_note = pickup_note
            @delivery_time_window = delivery_time_window
            @delivery_contact = delivery_contact
            @delivery_note = delivery_note
            @commodity_information_generator = commodity_information_generator
            @handling_unit_generator = handling_unit_generator
            @packaging_unit_generator = packaging_unit_generator
            @structure_options = structure_options
            @structure_options_class = structure_options_class

            super(**kwargs.reverse_merge(package_options_class: PackageOptions))
          end

          # @param structure [#id]
          # @return [StructureOptions]
          def options_for_structure(structure)
            structure_options.detect do |structure_option|
              structure_option.structure_id == structure.id
            end || structure_options_class.new(structure_id: nil)
          end

          private

          # @return [Array<StructureOptions>]
          attr_reader :structure_options

          # @return [Class<StructureOptions>]
          attr_reader :structure_options_class
        end
      end
    end
  end
end
