# frozen_string_literal: true

module FriendlyShipping
  # Base class for package options. Used when serializing API requests.
  class PackageOptions
    # @return [String] the ID for the package that belongs to these options
    attr_reader :package_id

    # @param package_id [String] the ID for the package  that belongs to these options
    # @param item_options [Array<ItemOptions>] the options for items in this package
    # @param item_options_class [Class] the class to use for item options when none are provided
    def initialize(
      package_id:,
      item_options: Set.new,
      item_options_class: ItemOptions
    )
      @package_id = package_id
      @item_options = item_options
      @item_options_class = item_options_class
    end

    # Finds and returns item options for the given item. If options cannot be
    # found, the `item_options_class` is used to construct new options.
    #
    # @param item [#id] the item for which to get options
    # @return [ItemOptions]
    def options_for_item(item)
      item_options.detect do |item_option|
        item_option.item_id == item.id
      end || item_options_class.new(item_id: nil)
    end

    private

    # @return [Array<ItemOptions>]
    attr_reader :item_options

    # @return [Class]
    attr_reader :item_options_class

    # Attempts to find a hash value for the given key. If no value is found, the
    # default value is returned.
    #
    # @param key [Symbol] the key to use
    # @param default [Object] the default value
    # @param kwargs [Hash] the hash to search
    def value_or_default(key, default, kwargs)
      kwargs.key?(key) ? kwargs.delete(key) : default
    end
  end
end
