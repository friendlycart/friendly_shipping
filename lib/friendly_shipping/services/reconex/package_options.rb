# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Options for each package in a Reconex quote request.
      class PackageOptions < FriendlyShipping::PackageOptions
        PACKAGING_TYPES = %w[
          Bags Bales Barrels Baskets Boxes Buckets Bulkheads Bundles
          Carboys Cartons Cases Chests Coils Crates Cylinders Drums
          Feet Firkins Hampers Hogsheads Kegs Packages Pails Pallets
          Pieces Racks Reels Rolls Skids SlipSheets Sows SuperSack
          Totes Trailers Truckload Trunks Tubes Unpackaged FloorLoaded
          Tanks PackingSlip ChepPallets EmptyTotes EmptyDrums EmptyContainers
          Carrier Gaylords PalletsStackable PalletsNonStackable Doors
          Skins Jambs BasePlate Carts Eaches
        ].freeze

        FREIGHT_CLASSES = %w[
          50 55 60 65 70 77.5 85 92.5 100 110 125 150 175 200 250 300 400 500
        ].freeze

        # @return [String] the NMFC freight class
        attr_reader :freight_class

        # @return [String] the NMFC commodity number
        attr_reader :nmfc_code

        # @return [String] the NMFC sub class
        attr_reader :sub_class

        # @return [String] the packaging type
        attr_reader :packaging

        # @return [String] the item description
        attr_reader :description

        # @param freight_class [String] the NMFC freight class
        # @param nmfc_code [String] the NMFC commodity number
        # @param sub_class [String] the NMFC sub class
        # @param packaging [String] the packaging type (default: "Pallets")
        # @param description [String] the item description
        # @param kwargs [Hash]
        # @option kwargs [String] :package_id the ID for the package
        def initialize(
          freight_class: nil,
          nmfc_code: nil,
          sub_class: nil,
          packaging: "Pallets",
          description: nil,
          **kwargs
        )
          @freight_class = freight_class
          @nmfc_code = nmfc_code
          @sub_class = sub_class
          @packaging = packaging
          @description = description
          validate_packaging!
          validate_freight_class!
          validate_nmfc_code!
          validate_sub_class!
          super(**kwargs)
        end

        private

        # @raise [ArgumentError] invalid packaging type
        def validate_packaging!
          return if packaging.nil?
          return if PACKAGING_TYPES.include?(packaging)

          raise ArgumentError, "Invalid packaging type: #{packaging}"
        end

        # @raise [ArgumentError] invalid freight class
        def validate_freight_class!
          return if freight_class.nil?
          return if FREIGHT_CLASSES.include?(freight_class)

          raise ArgumentError, "Invalid freight class: #{freight_class}"
        end

        # @raise [ArgumentError] invalid NMFC code
        def validate_nmfc_code!
          return if nmfc_code.nil?
          return if nmfc_code.match?(/\A\d+\z/)

          raise ArgumentError, "NMFC code must be numeric: #{nmfc_code}"
        end

        # @raise [ArgumentError] invalid sub class
        def validate_sub_class!
          return if sub_class.nil?
          return if sub_class.match?(/\A\d+\z/)

          raise ArgumentError, "Sub class must be numeric: #{sub_class}"
        end
      end
    end
  end
end
