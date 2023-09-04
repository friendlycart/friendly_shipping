# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::Ups::ParseModifierElement do
  let(:xml) do
    '<RateModifier>' \
      '<ModifierType>DTM</ModifierType>' \
      '<ModifierDesc>Destination Modifier</ModifierDesc>' \
      '<Amount>-0.60</Amount>' \
      '</RateModifier>'
  end
  let(:element) { Nokogiri.XML(xml).at('RateModifier') }

  describe '.call' do
    subject { described_class.call(element, currency_code: 'USD') }

    it { is_expected.to eq(["DTM (Destination Modifier)", Money.new(-60, 'USD')]) }

    context 'with nil element' do
      let(:element) { nil }

      it { is_expected.to be_nil }
    end
  end
end
