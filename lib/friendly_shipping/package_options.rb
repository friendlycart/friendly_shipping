# frozen_string_literal: true

module FriendlyShipping
  class PackageOptions
    attr_reader :package_id

    def initialize(
      package_id:,
      item_options: Set.new,
      item_options_finder: method(:find_item_options)
    )
      @package_id = package_id
      @item_options = item_options
      @item_options_finder = item_options_finder
    end

    def options_for_item(item)
      @item_options_finder.call(item_options, item)
    end

    private

    def find_item_options(item_options, item)
      item_options.detect { |item_option| item_option.item_id == item.id }
    end

    attr_reader :item_options
  end
end
