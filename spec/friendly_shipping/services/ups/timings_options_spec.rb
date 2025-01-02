# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::TimingOptions do
  subject { described_class.new }

  it 'has all the required attributes' do
    expect(subject.pickup).to be_a(Time)
    expect(subject.invoice_total).to eq(Money.new(5000, 'USD'))
    expect(subject.documents_only).to be false
    expect(subject.customer_context).to be nil
  end
end
