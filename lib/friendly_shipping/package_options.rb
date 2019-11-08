# frozen_string_literal: true

module FriendlyShipping
  class PackageOptions
    attr_reader :package_id

    def initialize(
      package_id:,
      item_options: Set.new,
      item_options_class: ItemOptions
    )
      @package_id = package_id
      @item_options = item_options
      @item_options_class = item_options_class
    end

    def options_for_item(item)
      item_options.detect do |item_option|
        item_option.item_id == item.id
      end || item_options_class.new(item_id: nil)
    end

    private

    attr_reader :item_options,
                :item_options_class
  end
end
