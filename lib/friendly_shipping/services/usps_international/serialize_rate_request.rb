# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UspsInternational
      # Serializes a rate request for the USPS international rating API
      class SerializeRateRequest
        class << self
          # Serialize a rate request into XML
          #
          # @param [Physical::Shipment] shipment The shipment we want to get rates for
          # @param [String] login The USPS login code
          # @param [RateEstimateOptions] options The options
          #   object to use with this request.
          # @return [String] The XML request body
          def call(shipment:, login:, options:)
            xml_builder = Nokogiri::XML::Builder.new do |xml|
              xml.IntlRateV2Request('USERID' => login) do
                xml.Revision("2")
                shipment.packages.each_with_index do |package, index|
                  xml.Package('ID' => index) do
                    xml.Pounds(pounds_for(package))
                    xml.Ounces(ounces_for(package))
                    xml.Machinable(machinable(package))
                    package_options = options.options_for_package(package)
                    xml.MailType(package_options.mail_type)
                    xml.ValueOfContents(package.items_value)
                    xml.Country(shipment.destination.country)
                    xml.Container(package_options.container)
                    if package_options.transmit_dimensions && package_options.container == 'VARIABLE'
                      xml.Width("%<width>0.2f" % { width: package.width.convert_to(:inches).value.to_f })
                      xml.Length("%<length>0.2f" % { length: package.length.convert_to(:inches).value.to_f })
                      xml.Height("%<height>0.2f" % { height: package.height.convert_to(:inches).value.to_f })

                      # When girth is present, the package is treated as non-rectangular
                      # when calculating dimensional weight. This results in a smaller
                      # dimensional weight than a rectangular package would have.
                      unless package_options.rectangular
                        xml.Girth("%<girth>0.2f" % { girth: girth(package) })
                      end
                      xml.CommercialFlag(package_options.commercial_pricing)
                      xml.CommercialPlusFlag(package_options.commercial_plus_pricing)
                    end
                  end
                end
              end
            end
            xml_builder.to_xml
          end

          private

          # @param package [Physical::Package]
          # @return [String] 'true' or 'false'
          def machinable(package)
            FriendlyShipping::Services::USPSShip::MachinablePackage.new(package).machinable? ? 'true' : 'false'
          end

          # @param package [Physical::Package]
          # @return [Numeric] the ounces part of the package weight, between 1 and 15.999
          def ounces_for(package)
            ounces = (package.weight.convert_to(:ounces).value.to_f % 16).round(2).ceil
            ounces == 16 ? 15.999 : [ounces, 1].max
          end

          # @param package [Physical::Package]
          # @return [Integer] the whole pounds of the package weight
          def pounds_for(package)
            package.weight.convert_to(:pounds).value.to_f.floor
          end

          # @param package [Physical::Package]
          # @return [Float] the girth in inches, calculated from the two smallest dimensions
          def girth(package)
            width, length = package.dimensions.sort.first(2)
            (width.scale(2) + length.scale(2)).convert_to(:inches).value.to_f
          end
        end
      end
    end
  end
end
