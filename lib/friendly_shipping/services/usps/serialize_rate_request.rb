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
          def call(shipment:, login:, shipping_method: nil)
            xml_builder = Nokogiri::XML::Builder.new do |xml|
              xml.RateV4Request('USERID' => login) do
                shipment.packages.each_with_index do |package, index|
                  xml.Package('ID' => index) do
                    xml.Service(service_code_by(shipping_method, package))
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
                    if ['RECTANGULAR', 'VARIABLE'].include?(container)
                      xml.Width("%<width>0.2f" % { width: package.width.convert_to(:inches).value.to_f })
                      xml.Length("%<length>0.2f" % { length: package.length.convert_to(:inches).value.to_f })
                      xml.Height("%<height>0.2f" % { height: package.height.convert_to(:inches).value.to_f })
                      xml.Girth("%<girth>0.2f" % { girth: girth(package) })
                    end
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

          def service_code_by(shipping_method, package)
            return 'ALL' unless shipping_method

            if package.properties[:commercial_pricing]
              "#{shipping_method.service_code} COMMERCIAL"
            else
              shipping_method.service_code
            end
          end

          def ounces_for(package)
            ounces = package.weight.convert_to(:ounces).value.to_f.round(2).ceil
            ounces == 16 ? 15.999 : [ounces, 1].max
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
