# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Ups
      class SerializePackageNode
        def self.call(xml:, package:)
          xml.Package do
            xml.PackagingType do
              xml.Code('02')
            end

            if package.dimensions.all? { |dim| !dim.value.zero? && !dim.value.infinite? }
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

            if package.properties[:shipper_release]
              xml.PackageServiceOptions do
                xml.ShipperReleaseIndicator
              end
            end

            Array.wrap(package.properties[:reference_numbers]).each do |reference_number_info|
              xml.ReferenceNumber do
                xml.Code(reference_number_info[:code] || "")
                xml.Value(reference_number_info[:value])
              end
            end
          end
        end
      end
    end
  end
end
