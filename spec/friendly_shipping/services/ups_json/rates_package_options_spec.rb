# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::UpsJson::RatesPackageOptions do
  subject(:options) { described_class.new(package_id: 'my_package_id') }

  describe 'package_id' do
    subject { options.package_id }

    it { is_expected.to eq('my_package_id') }
  end
end
