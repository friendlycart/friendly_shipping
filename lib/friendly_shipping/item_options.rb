# frozen_string_literal: true

module FriendlyShipping
  class ItemOptions
    attr_reader :item_id

    def initialize(item_id:)
      @item_id = item_id
    end
  end
end
