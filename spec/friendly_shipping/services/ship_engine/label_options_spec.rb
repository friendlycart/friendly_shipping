# frozen_string_literal: true

require 'spec_helper'
require 'friendly_shipping/services/ship_engine/label_options'
require 'friendly_shipping/services/ship_engine/label_customs_options'

RSpec.describe FriendlyShipping::Services::ShipEngine::LabelOptions do
  subject(:options) { described_class.new(shipping_method: double) }

  [
    :shipping_method,
    :label_format,
    :label_download_type,
    :label_image_id,
    :customs_options
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  it_behaves_like "overrideable package options class" do
    let(:default_class) { FriendlyShipping::Services::ShipEngine::LabelPackageOptions }
    let(:required_attrs) { { shipping_method: double } }
  end

  context "customs_options" do
    subject(:customs_options) { options.customs_options }
    it { is_expected.to be_a(FriendlyShipping::Services::ShipEngine::LabelCustomsOptions) }
  end

  context "customs_items_serializer" do
    subject(:customs_items_serializer) { options.customs_items_serializer }

    it { is_expected.to be(FriendlyShipping::Services::ShipEngine::CustomsItemsSerializer) }

    context "can be overridden" do
      subject(:options) do
        described_class.new(shipping_method: double,
                            customs_items_serializer: alternate_serializer).customs_items_serializer
      end

      let(:alternate_serializer) { Class }

      it { is_expected.to eq(Class) }
    end
  end
end
