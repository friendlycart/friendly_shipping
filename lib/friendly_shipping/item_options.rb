# frozen_string_literal: true

module FriendlyShipping
  # Base class for item options. Used when serializing API requests.
  class ItemOptions
    # @return [String] the ID for the item that belongs to these options
    attr_reader :item_id

    # @param item_id [String] the ID for the item that belongs to these options
    def initialize(item_id:)
      @item_id = item_id
    end
  end
end
