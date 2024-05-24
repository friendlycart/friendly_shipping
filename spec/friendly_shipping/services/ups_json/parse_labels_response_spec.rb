# frozen_string_literal: true

require "spec_helper"

RSpec.describe FriendlyShipping::Services::UpsJson::ParseLabelsResponse do
  subject(:call) { described_class.call(request: request, response: response) }

  let(:request) { FriendlyShipping::Request.new(url: "http://www.example.com", debug: true) }
  let(:response) { double(body: response_body, headers: {}) }
  let(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "ups_json", "labels_two_packages.json")) }

  it "returns a successful result with the expected data for two packages" do
    expect(call).to be_success
    expect(call.value!.data).to be_a(Array)
    expect(call.value!.data.length).to eq(2)
    first_label = call.value!.data.first
    expect(first_label).to be_a(FriendlyShipping::Services::UpsJson::Label)
    expect(first_label.shipment_id).to eq("1ZXXXXXXXXXXXXXXXX")
    expect(first_label.tracking_number).to eq("1ZXXXXXXXXXXXXXXXX")
    expect(first_label.usps_tracking_number).to be_nil
    expect(first_label.label_data).to be_a(String)
    expect(first_label.label_format).to eq("ZPL")
    expect(first_label.label_href).to eq("https://www.ups.com/uel/llp/1ZY9319W0399389763/link/labelAll/XSA/fq3Gmu0fyI6kwlDU5kQBgjKtuyD1mNfat76UjFtChj8e/en_US?loc=en_US&cie=true&pdr=false")
    expect(first_label.cost).to eq(Money.new(3074, "USD"))
    expect(first_label.shipment_cost).to eq(Money.new(5699, "USD"))
    expect(first_label.data).to be_a(Hash)
    expect(first_label.data[:cost_breakdown]).to eq({
                                                      "BaseServiceCharge" => Money.new(2579, 'USD'),
                                                      "FUEL SURCHARGE" => Money.new(495, 'USD')
                                                    })
    expect(first_label.data[:negotiated_rate]).to be_nil
    expect(first_label.data[:customer_context]).to be_nil

    second_label = call.value!.data.last
    expect(second_label).to be_a(FriendlyShipping::Services::UpsJson::Label)
    expect(second_label.shipment_id).to eq("1ZXXXXXXXXXXXXXXXX")
    expect(second_label.tracking_number).to eq("1ZXXXXXXXXXXXXXXXX")
    expect(second_label.label_data).to be_a(String)
    expect(second_label.label_format).to eq("ZPL")
    expect(second_label.label_href).to eq("https://www.ups.com/uel/llp/1ZY9319W0399389763/link/labelAll/XSA/fq3Gmu0fyI6kwlDU5kQBgjKtuyD1mNfat76UjFtChj8e/en_US?loc=en_US&cie=true&pdr=false")
    expect(second_label.cost).to eq(Money.new(1495, "USD"))
    expect(second_label.shipment_cost).to eq(Money.new(5699, "USD"))
    expect(second_label.data).to be_a(Hash)
    expect(second_label.data[:cost_breakdown]).to eq({
                                                       "BaseServiceCharge" => Money.new(1215, 'USD'),
                                                       "FUEL SURCHARGE" => Money.new(180, 'USD'),
                                                       "PEAK SEASON" => Money.new(100, 'USD')
                                                     })
    expect(second_label.data[:negotiated_rate]).to be_nil
    expect(second_label.data[:customer_context]).to be_nil
  end

  context "with a negotiated rate" do
    let!(:response_body) { File.read(File.join(gem_root, "spec", "fixtures", "ups_json", "labels_with_negotiated_rates.json")) }

    it "returns the negotiated rate if available" do
      expect(call.value!.data.first.data[:negotiated_rate]).to eq(Money.new(1436, "USD"))
    end
  end
end
