# frozen_string_literal: true

module FriendlyShipping
  module Services
    class Reconex
      # Options for a Reconex UpdateLoad request.
      class UpdateLoadOptions < LoadOptions
        # @return [Integer] the load ID to update
        attr_reader :load_id

        # @return [String, nil] the billing ID
        attr_reader :billing_id

        # @return [String, nil] the PRO number
        attr_reader :pro_number

        # @return [String, nil] the sender email address
        attr_reader :email_from

        # @return [String, nil] the recipient email address
        attr_reader :email_to

        # @return [String, nil] the email subject
        attr_reader :email_subject

        # @return [String, nil] the email body
        attr_reader :email_body

        def initialize(
          load_id:,
          billing_id: nil,
          pro_number: nil,
          email_from: nil,
          email_to: nil,
          email_subject: nil,
          email_body: nil,
          scac: nil,
          dock_type: nil,
          **kwargs
        )
          @load_id = load_id
          @billing_id = billing_id
          @pro_number = pro_number
          @email_from = email_from
          @email_to = email_to
          @email_subject = email_subject
          @email_body = email_body
          validate_load_id!
          super(scac: scac, dock_type:, **kwargs)
        end

        private

        # @raise [ArgumentError] missing load_id
        def validate_load_id!
          raise ArgumentError, "load_id is required" if load_id.nil?
        end

        # Override to allow nil scac for updates (not re-booking).
        def validate_scac!
          return if scac.nil?

          super
        end

        # Override to allow nil dock_type for updates.
        def validate_dock_type!
          return if dock_type.nil?

          super
        end
      end
    end
  end
end
