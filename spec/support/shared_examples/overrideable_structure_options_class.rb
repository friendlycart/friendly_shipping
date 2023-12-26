# frozen_string_literal: true

RSpec.shared_examples "overrideable structure options class" do
  describe "structure options class" do
    subject { options.options_for_structure(double(structure_id: "structure")) }

    it { is_expected.to be_a(default_class) }

    context "when a custom class is passed" do
      let(:options) do
        described_class.new(
          **required_attrs.merge(structure_options_class: FriendlyShipping::StructureOptions)
        )
      end

      it { is_expected.to be_a(FriendlyShipping::StructureOptions) }
    end
  end
end
