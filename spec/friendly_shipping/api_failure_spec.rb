# frozen_string_literal: true

RSpec.describe FriendlyShipping::ApiFailure do
  it 'aliases ApiResult' do
    expect(described_class).to eq(FriendlyShipping::ApiResult)
  end
end
