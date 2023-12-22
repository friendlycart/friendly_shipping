# frozen_string_literal: true

RSpec.shared_examples "overrideable package options class" do
  describe "package options class" do
    subject { options.options_for_package(double(package_id: "package")) }

    it { is_expected.to be_a(default_class) }

    context "when a custom class is passed" do
      let(:options) do
        described_class.new(
          **required_attrs.merge(package_options_class: FriendlyShipping::PackageOptions)
        )
      end

      it { is_expected.to be_a(FriendlyShipping::PackageOptions) }
    end
  end
end
