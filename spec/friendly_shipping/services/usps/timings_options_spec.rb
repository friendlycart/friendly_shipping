# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Usps::TimingOptions do
  subject { described_class.new }

  it 'has the right things' do
    expect(subject.pickup).to be_a(Time)
    expect(subject.shipping_method).to be nil
  end
end
