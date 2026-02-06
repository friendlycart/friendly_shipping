# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Options for each package in a Reconex quote request.
      class PackageOptions < FriendlyShipping::PackageOptions
        # @return [String] the NMFC freight class
        attr_reader :freight_class

        # @return [String] the NMFC commodity number
        attr_reader :nmfc_code

        # @return [String] the packaging type
        attr_reader :packaging

        # @return [String] the item description
        attr_reader :description

        # @param freight_class [String] the NMFC freight class
        # @param nmfc_code [String] the NMFC commodity number
        # @param packaging [String] the packaging type (default: "Pallets")
        # @param description [String] the item description
        # @param kwargs [Hash]
        # @option kwargs [String] :package_id the ID for the package
        def initialize(
          freight_class: nil,
          nmfc_code: nil,
          packaging: "Pallets",
          description: nil,
          **kwargs
        )
          @freight_class = freight_class
          @nmfc_code = nmfc_code
          @packaging = packaging
          @description = description
          super(**kwargs)
        end
      end
    end
  end
end
