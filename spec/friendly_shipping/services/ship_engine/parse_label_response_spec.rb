# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::ParseLabelResponse, vcr: { cassette_name: 'shipengine/labels/success' } do
  subject { described_class.call(request: request, response: response) }
  let(:request) { double(debug: true) }
  let(:response) { double(body: response_body) }
  let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ship_engine', 'usps_labels_success.json')) }

  let(:label) { subject.data.first }

  it "returns an Array of labels" do
    expect(subject.data).to be_a Array
    expect(label).to be_a FriendlyShipping::Label
  end

  it "contains correct data in the carrier" do
    expect(label.id).to be_present
    expect(label.shipment_id).to eq('se-1146755')
    expect(label.tracking_number).to eq('9999999999999')
    expect(label.service_code).to eq("usps_priority_mail")
    expect(label.label_href).to start_with('https://')
    expect(label.label_format).to eq(:pdf)
    expect(label.shipment_cost).to eq(0.0)
    expect(label.cost).to eq(0.0)
    expect(subject.original_request).to eq(request)
    expect(subject.original_response).to eq(response)
  end

  context "apc label" do
    let(:response_body) { File.read(File.join(gem_root, 'spec', 'fixtures', 'ship_engine', 'apc_labels_success.json')) }

    it "contains the correct data" do
      expect(label.id).to be_present
      expect(label.shipment_id).to eq('se-911476892')
      expect(label.tracking_number).to eq('1913101260000007')
      expect(label.service_code).to eq("apc_priority_ddp_delcon")
      expect(label.label_href).to start_with('https://')
      expect(label.label_format).to eq(:pdf)
      expect(label.shipment_cost.to_f).to eq(47.77)
      expect(label.cost.to_f).to eq(47.77)
      expect(subject.original_request).to eq(request)
      expect(subject.original_response).to eq(response)
    end
  end
end
