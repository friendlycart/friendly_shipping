# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      # Options for an email notification requested in a UPS Freight ship request.
      class LabelEmailOptions
        # Maps friendly names to email type codes.
        EMAIL_TYPES = {
          ship_notification: '001',
          delivery_notification: '002',
          exception_notification: '003',
          bol_labels: '004'
        }.freeze

        # @return [Symbol] the type of notification (a key of {EMAIL_TYPES})
        attr_reader :email_type

        # @return [String] the email address to send to
        attr_reader :email

        # @return [String] the email address used for undeliverable email
        attr_reader :undeliverable_email

        # @return [String, nil] the email subject
        attr_reader :subject

        # @return [String, nil] the email body text
        attr_reader :body

        # @param email [String] the email address to send to
        # @param email_type [Symbol] the type of notification (see {EMAIL_TYPES})
        # @param undeliverable_email [String] the email address used for undeliverable email
        # @param subject [String, nil] the email subject
        # @param body [String, nil] the email body text
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

        # @return [String] the code for {#email_type}
        def email_type_code
          EMAIL_TYPES.fetch(email_type)
        end
      end
    end
  end
end
