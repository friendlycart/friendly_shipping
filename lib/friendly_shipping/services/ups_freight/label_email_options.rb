# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class LabelEmailOptions
        EMAIL_TYPES = {
          ship_notification: '001',
          delivery_notification: '002',
          exception_notification: '003',
          bol_labels: '004'
        }.freeze

        attr_reader :email_type,
                    :email,
                    :undeliverable_email,
                    :subject,
                    :body

        def initialize(
          email:,
          email_type:,
          undeliverable_email:,
          subject: nil,
          body: nil
        )
          @email = email
          @email_type = email_type
          @undeliverable_email = undeliverable_email
          @subject = subject
          @body = body
        end

        def email_type_code
          EMAIL_TYPES.fetch(email_type)
        end
      end
    end
  end
end
