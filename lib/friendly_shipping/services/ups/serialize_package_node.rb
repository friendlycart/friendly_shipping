# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializePackageNode
        def self.call(
          xml:,
          package:,
          reference_numbers: {},
          delivery_confirmation_code: nil,
          shipper_release: false,
          transmit_dimensions: true
        )
          xml.Package do
            xml.PackagingType do
              xml.Code('02')
            end

            if package.items.any?(&:description)
              xml.Description(package.items.map(&:description).compact.join(', '))
            end

            if transmit_dimensions && package.dimensions.all? { |dim| !dim.value.zero? && !dim.value.infinite? }
              xml.Dimensions do
                xml.UnitOfMeasurement do
                  xml.Code('IN')
                end
                xml.Length(package.length.convert_to(:inches).value.to_f.round(3))
                xml.Width(package.width.convert_to(:inches).value.to_f.round(3))
                xml.Height(package.height.convert_to(:inches).value.to_f.round(3))
              end
            end

            xml.PackageWeight do
              xml.UnitOfMeasurement do
                xml.Code('LBS')
              end

              xml.Weight([package.weight.convert_to(:pounds).value.to_f.round(2).ceil, 1].max)
            end

            xml.PackageServiceOptions do
              if shipper_release
                xml.ShipperReleaseIndicator
              end
              if delivery_confirmation_code
                xml.DeliveryConfirmation do
                  xml.DCISType(delivery_confirmation_code)
                end
              end
            end

            reference_numbers.each do |reference_code, reference_number|
              xml.ReferenceNumber do
                xml.Code(reference_code)
                xml.Value(reference_number)
              end
            end
          end
        end
      end
    end
  end
end
