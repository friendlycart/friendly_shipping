# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      # Generates the hash representing a package in UPS rates and labels request payloads.
      class GeneratePackageHash
        class << self
          # @param package [Physical::Package] the package to convert
          # @param delivery_confirmation_code [Integer, nil] the UPS delivery confirmation code for the package
          # @param shipper_release [Boolean] whether the package may be released without a signature
          # @param transmit_dimensions [Boolean] whether to include the package's dimensions, if they are all
          #   finite and non-zero
          # @param declared_value [Boolean] whether to include the declared value (only applied for rates)
          # @param package_flavor [String, nil] `"rates"` for a rates request, otherwise the hash is built for labels
          # @param reference_numbers [Hash, nil] reference number codes mapped to reference number values
          # @return [Hash] the package hash, with blank values removed
          def call(package:,
                   delivery_confirmation_code: nil,
                   shipper_release: false,
                   transmit_dimensions: true,
                   declared_value: false,
                   package_flavor: nil,
                   reference_numbers: nil)
            # UPS consistency across apis is a bit of a mess
            packaging_type_key = package_flavor == "rates" ? :PackagingType : :Packaging

            package_hash = {
              packaging_type_key => {
                Code: "02"
              },
              PackageWeight: {
                UnitOfMeasurement: {
                  Code: "LBS"
                },
                Weight: [package.weight.convert_to(:pounds).value.to_f.round(2), 1].max.to_s
              },
              PackageServiceOptions: {},
              Description: package.items.map(&:description).compact.uniq.join(', ').slice(0, 35) # required for return labels
            }

            if transmit_dimensions && package.dimensions.all? { |dim| !dim.value.zero? && !dim.value.infinite? }
              package_hash[:Dimensions] = {
                UnitOfMeasurement: {
                  Code: "IN"
                },
                Length: package.length.convert_to(:inches).value.to_f.round(2).to_s,
                Width: package.width.convert_to(:inches).value.to_f.round(2).to_s,
                Height: package.height.convert_to(:inches).value.to_f.round(2).to_s
              }
            end

            package_hash[:PackageServiceOptions][:ShipperReleaseIndicator] = true if shipper_release
            if delivery_confirmation_code
              package_hash[:PackageServiceOptions][:DeliveryConfirmation] = { DCISType: delivery_confirmation_code }
            end

            total_value = package.items.inject(Money.new(0, "USD")) do |package_sum, item|
              package_sum + (item.cost || Money.new(0, "USD"))
            end

            # this key is invalid for labels, UPS responds with "Accessory may not be combined with the product."
            if package_flavor == "rates" && declared_value
              package_hash[:PackageServiceOptions][:DeclaredValue] = {
                CurrencyCode: total_value.currency.iso_code,
                MonetaryValue: total_value.to_s
              }
            end

            if reference_numbers.present?
              package_hash[:ReferenceNumber] = reference_numbers.map do |code, value|
                {
                  Code: code.to_s,
                  Value: value.to_s
                }
              end
            end

            package_hash[:PackageServiceOptions].compact_blank!
            package_hash.compact_blank!
          end
        end
      end
    end
  end
end
