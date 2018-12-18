require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine do
  describe 'initialization' do
    subject(:service) { described_class.new(token: "s3cr3t") }

    it { is_expected.not_to respond_to :token }
  end
end
