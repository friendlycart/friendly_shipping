# frozen_string_literal: true

require 'friendly_shipping/services/usps/machinable_package'

module FriendlyShipping
  module Services
    class Usps
      class SerializeRateRequest
        MAX_REGULAR_PACKAGE_SIDE = Measured::Length(12, :inches)

        class << self
          # @param [Physical::Shipment] shipment The shipment we want to get rates for
          #   shipment.packages[0].properties[:box_name] Can be :variable or a
          #     flat rate container defined in CONTAINERS.
          # @param [String] login The USPS login code
          # @param [FriendlyShipping::Services::Usps::RateEstimateOptions] options The options
          #   object to use with this request.
          # @return Array<[FriendlyShipping::Rate]> A set of Rates that this package may be sent with
          def call(shipment:, login:, options:)
            xml_builder = Nokogiri::XML::Builder.new do |xml|
              xml.RateV4Request('USERID' => login) do
                shipment.packages.each_with_index do |package, index|
                  package_options = options.options_for_package(package)
                  xml.Package('ID' => index) do
                    xml.Service(package_options.service_code)
                    if package_options.first_class_mail_type
                      xml.FirstClassMailType(package_options.first_class_mail_type_code)
                    end
                    xml.ZipOrigination(shipment.origin.zip)
                    xml.ZipDestination(shipment.destination.zip)
                    xml.Pounds(0)
                    xml.Ounces(ounces_for(package))
                    size_code = size_code_for(package)
                    xml.Container(package_options.container_code)
                    xml.Size(size_code)
                    if package_options.transmit_dimensions && package_options.container_code == 'VARIABLE'
                      xml.Width("%<width>0.2f" % { width: package.width.convert_to(:inches).value.to_f })
                      xml.Length("%<length>0.2f" % { length: package.length.convert_to(:inches).value.to_f })
                      xml.Height("%<height>0.2f" % { height: package.height.convert_to(:inches).value.to_f })

                      # When girth is present, the package is treated as non-rectangular
                      # when calculating dimensional weight. This results in a smaller
                      # dimensional weight than a rectangular package would have.
                      unless package_options.rectangular
                        xml.Girth("%<girth>0.2f" % { girth: girth(package) })
                      end
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
