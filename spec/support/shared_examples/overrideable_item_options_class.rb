# frozen_string_literal: true

RSpec.shared_examples "overrideable item options class" do
  describe "item options class" do
    subject { options.options_for_item(double(item_id: "item")) }

    it { is_expected.to be_a(default_class) }

    context "when a custom class is passed" do
      let(:options) do
        described_class.new(
          package_id: "package",
          item_options_class: FriendlyShipping::ItemOptions
        )
      end

      it { is_expected.to be_a(FriendlyShipping::ItemOptions) }
    end
  end
end
