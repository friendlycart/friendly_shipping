# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsJson
      class GeneratePackageHash
        class << self
          def call(package:,
                   delivery_confirmation_code: nil,
                   shipper_release: false,
                   transmit_dimensions: true,
                   package_flavor: nil)
            # UPS consistency across apis is a bit of a mess
            packaging_type_key = package_flavor == "rates" ? "PackagingType" : "Packaging"

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
                Length: package.length.convert_to(:inches).value.to_f.round(3).to_s,
                Width: package.width.convert_to(:inches).value.to_f.round(3).to_s,
                Height: package.height.convert_to(:inches).value.to_f.round(3).to_s
              }
            end

            package_hash[:PackageServiceOptions][:ShipperReleaseIndicator] = true if shipper_release
            if delivery_confirmation_code
              package_hash[:PackageServiceOptions][:DeliveryConfirmation] = { DCISType: delivery_confirmation_code }
            end

            total_value = package.items.inject(Money.new(0, "USD")) do |package_sum, item|
              package_sum + (item.cost || Money.new(0, "USD"))
            end

            # since this key is invalid for labels, UPS responds with "Accessory may not be combined with the product."
            if package_flavor == "rates"
              package_hash[:PackageServiceOptions][:DeclaredValue] = {
                CurrencyCode: "USD",
                MonetaryValue: total_value.cents.to_s
              }
            end

            package_hash
          end
        end
      end
    end
  end
end
