# frozen_string_literal: true

module FriendlyShipping
  module Services
    class UpsFreight
      class LabelOptions < RatesOptions
        attr_reader :document_options

        def initialize(
          document_options: [],
          **kwargs
        )
          @document_options = document_options
          super kwargs
        end
      end
    end
  end
end
