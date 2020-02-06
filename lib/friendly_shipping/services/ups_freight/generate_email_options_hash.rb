# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class GenerateEmailOptionsHash
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
