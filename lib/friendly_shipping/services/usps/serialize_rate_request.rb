# frozen_string_literal: true

require 'friendly_shipping/services/usps/machinable_package'

module FriendlyShipping
  module Services
    class Usps
      class SerializeRateRequest
        MAX_REGULAR_PACKAGE_SIDE = Measured::Length(12, :inches)

        class << self
          # @param [Physical::Shipment] shipment The shipment we want to get rates for
          #   shipment.packages[0].properties[:box_code] Can be :rectangular, :variable,
          #     or a flat rate container defined in CONTAINERS.
          # @param [String] login The USPS login code
          # @param [FriendlyShipping::ShippingMethod] service The shipping methods we want to get rates
          #   for. If empty, we get all of them
          # @return Array<[FriendlyShipping::Rate]> A set of Rates that this package may be sent with
          def call(shipment:, login:, service: nil)
            xml_builder = Nokogiri::XML::Builder.new do |xml|
              xml.RateV4Request('USERID' => login) do
                shipment.packages.each do |package|
                  xml.Package('ID' => package.id) do
                    xml.Service(service_code_by(service, package))
                    if package.properties[:first_class_mail_type]
                      xml.FirstClassMailType(FIRST_CLASS_MAIL_TYPES[package.properties[:first_class_mail_type]])
                    end
                    xml.ZipOrigination(shipment.origin.zip)
                    xml.ZipDestination(shipment.destination.zip)
                    xml.Pounds(0)
                    xml.Ounces(ounces_for(package))
                    size_code = size_code_for(package)
                    container = CONTAINERS[package.properties[:box_name] || :rectangular]
                    xml.Container(container)
                    xml.Size(size_code)
                    xml.Width("%0.2f" % package.width.convert_to(:inches).value.to_f)
                    xml.Length("%0.2f" % package.length.convert_to(:inches).value.to_f)
                    xml.Height("%0.2f" % package.height.convert_to(:inches).value.to_f)
                    xml.Girth("%0.2f" % girth(package))
                    xml.Machinable(machinable(package))
                  end
                end
              end
            end
            xml_builder.to_xml
          end

          private

          def machinable(package)
            MachinablePackage.new(package).machinable? ? 'TRUE' : 'FALSE'
          end

          def size_code_for(package)
            if package.dimensions.max <= MAX_REGULAR_PACKAGE_SIDE
              'REGULAR'
            else
              'LARGE'
            end
          end

          def service_code_by(service, package)
            return 'ALL' unless service

            if package.properties[:commercial_pricing]
              "#{service.service_code} COMMERCIAL"
            else
              service.service_code
            end
          end

          def ounces_for(package)
            ounces = package.weight.convert_to(:ounces).value.to_f.round(2).ceil
            ounces == 16 ? 15.999 : [ounces, 1].max
          end

          def strip_zip(zip)
            zip.to_s.scan(/\d{5}/).first || zip
          end

          def girth(package)
            width, length = package.dimensions.sort.first(2)
            (width.scale(2) + length.scale(2)).convert_to(:inches).value.to_f
          end
        end
      end
    end
  end
end
