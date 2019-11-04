# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateUpsSecurityHash
        def self.call(login:, password:, key:)
          {
            UPSSecurity: {
              UsernameToken: {
                Username: login,
                Password: password
              },
              ServiceAccessToken: {
                AccessLicenseNumber: key
              }
            }
          }
        end
      end
    end
  end
end
