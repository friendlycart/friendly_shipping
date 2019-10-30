# frozen_string_literal: true

module FriendlyShipping
  module Types
    include Dry.Types

    Money = Types.Instance(::Money)
  end
end
