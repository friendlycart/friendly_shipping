# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Generates the EMailInformation hash of the ShipmentServiceOptions for UPS Freight ship requests.
      class GenerateEmailOptionsHash
        # @param email_options [LabelEmailOptions] the email options
        # @return [Hash] the email information hash
        def self.call(email_options:)
          {
            EMailInformation: {
              EMailType: {
                Code: email_options.email_type_code,
              },
              EMail: {
                EMailAddress: email_options.email,
                UndeliverableEMailAddress: email_options.undeliverable_email,
                EMailText: email_options.body,
                Subject: email_options.subject
              }.compact
            }
          }
        end
      end
    end
  end
end
