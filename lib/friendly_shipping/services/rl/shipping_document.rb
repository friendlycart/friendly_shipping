# frozen_string_literal: true

module FriendlyShipping
  module Services
    class RL
      class ShippingDocument
        attr_reader :binary, :format

        # @param [String] binary The binary data
        # @param [String] format The format of the binary data
        def initialize(
          binary:,
          format: :pdf
        )
          @binary = binary
          @format = format
        end

        def valid?
          binary.present? && format.present?
        end

        def decoded_binary
          Base64.decode64(binary)
        end
      end
    end
  end
end
