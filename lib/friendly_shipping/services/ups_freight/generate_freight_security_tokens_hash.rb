# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateFreightSecurityTokensHash
        class << self
          def call(login:, password:, key:)
            {
              UPSSecurity: {
                ServiceAccessToken: {
                  AccessLicenseNumber: key
                },
                UsernameToken: {
                  Password: login,
                  Username: password
                }
              }
            }
          end
        end
      end
    end
  end
end
