require 'spec_helper'

RSpec.describe FriendlyShipping::Services::ShipEngine::ParseLabelResponse, vcr: { cassette_name: 'shipengine/labels/success' } do
  subject { described_class.new(response: response).call }
  let(:response) { double(body: response_body) }
  let(:response_body) { File.open(File.join(gem_root, 'spec', 'fixtures', 'ship_engine', 'labels_success.json')).read }

  let(:label) { subject.first }

  it "returns an Array of labels" do
    expect(subject).to be_a Array
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
  end
end
