# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class LabelOptions < RatesOptions
        attr_reader :document_options,
                    :email_options,
                    :pickup_options,
                    :delivery_options,
                    :pickup_instructions,
                    :delivery_instructions,
                    :handling_instructions

        def initialize(
          document_options: [],
          email_options: [],
          pickup_options: nil,
          delivery_options: nil,
          pickup_instructions: nil,
          delivery_instructions: nil,
          handling_instructions: nil,
          **kwargs
        )
          @pickup_options = pickup_options
          @delivery_options = delivery_options
          @document_options = document_options
          @email_options = email_options
          @pickup_instructions = pickup_instructions
          @delivery_instructions = delivery_instructions
          @handling_instructions = handling_instructions
          super kwargs
        end
      end
    end
  end
end
