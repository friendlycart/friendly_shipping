# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::LabelPackageOptions do
  subject(:options) { described_class.new(package_id: 'package') }

  [
    :delivery_confirmation_code,
    :reference_numbers,
    :shipper_release,
    :declared_value
  ].each do |message|
    it { is_expected.to respond_to(message) }
  end

  it_behaves_like "overrideable item options class" do
    let(:default_class) { FriendlyShipping::Services::Ups::LabelItemOptions }
  end

  describe 'delivery_confirmation_code' do
    subject { options.delivery_confirmation_code }

    it { is_expected.to be nil }

    context 'if delivery confirmation is set' do
      let(:options) { described_class.new(package_id: 'my_package_id', delivery_confirmation: :delivery_confirmation_signature_required) }

      it { is_expected.to eq 2 }
    end
  end
end
