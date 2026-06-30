# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::TForceFreight::GenerateDocumentsRequestHash do
  describe ".call" do
    subject(:call) { described_class.call(pro: pro, document_categories: document_categories) }

    let(:pro) { "885728922" }
    let(:document_categories) { [:bill_of_lading] }

    it "passes the PRO number through" do
      expect(call[:pro]).to eq("885728922")
    end

    it "maps friendly category names to codes" do
      expect(call[:documentCategories]).to eq(["BOL"])
    end

    context "with multiple categories" do
      let(:document_categories) { %i[bill_of_lading claims delivery_receipt invoice weight_certificate] }

      it "maps each category to its code" do
        expect(call[:documentCategories]).to eq(%w[BOL CLM DR INVC WGHT])
      end
    end

    context "with an unknown category" do
      let(:document_categories) { [:nope] }

      it "raises a KeyError" do
        expect { call }.to raise_error(KeyError)
      end
    end
  end
end
