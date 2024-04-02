# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip do
  subject(:service) { described_class.new(access_token: access_token) }

  let(:access_token) do
    FriendlyShipping::Services::USPSShip::AccessToken.new(
      token_type: "Bearer",
      expires_in: 3599,
      raw_token: "secret_token"
    )
  end

  let(:shipping_method) do
    FriendlyShipping::Services::USPSShip::SHIPPING_METHODS.find do |sm|
      sm.service_code == "USPS_GROUND_ADVANTAGE"
    end
  end

  describe "#carriers" do
    subject(:carriers) { service.carriers }
    it { is_expected.to be_success }
    it { expect(carriers.value!).to eq([FriendlyShipping::Services::USPSShip::CARRIER]) }
  end

  describe "#create_access_token" do
    subject(:create_access_token) do
      service.create_access_token(
        client_id: "client-id",
        client_secret: "client-secret"
      )
    end

    let(:response) do
      instance_double(
        RestClient::Response,
        code: 200,
        body: %({
          "token_type": "Bearer",
          "expires_in": 3599,
          "access_token": "XYADfw4Hz2KdN_sd8N4TzMo9"
        }),
        headers: {
          "Cache-Control" => "no-store, no-cache",
          "Content-Type" => "application/json; charset=utf-8"
        }
      )
    end

    before do
      expect(RestClient).to receive(:post).with(
        "https://api.usps.com/oauth2/v3/token",
        "client_id=client-id&client_secret=client-secret&grant_type=client_credentials",
        { Accept: "application/json", Content_Type: "application/x-www-form-urlencoded" }
      ).and_return(response)
    end

    it "makes API request and returns access token" do
      result = create_access_token
      expect(result).to be_success
      expect(result.value!).to be_a(FriendlyShipping::ApiResult)

      access_token = result.value!.data
      expect(access_token).to be_a(FriendlyShipping::Services::USPSShip::AccessToken)
      expect(access_token.token_type).to eq("Bearer")
      expect(access_token.expires_in).to eq(3599)
      expect(access_token.raw_token).to eq("XYADfw4Hz2KdN_sd8N4TzMo9")
    end
  end

  describe "#rate_estimates" do
    subject(:rate_estimates) { service.rate_estimates(shipment, options: options) }

    let(:shipment) { Physical::Shipment.new(packages: packages, origin: origin, destination: destination) }

    let(:origin) do
      Physical::Location.new(
        city: "Richmond",
        zip: "23224",
        region: "VA",
        country: "US"
      )
    end

    let(:destination) do
      Physical::Location.new(
        city: "Eureka",
        zip: "63025",
        region: "MO",
        country: "US"
      )
    end

    let(:packages) { [package_one, package_two] }

    let(:package_one) do
      Physical::Package.new(
        id: "my_package_1",
        weight: Measured::Weight(10.523, :lbs),
        dimensions: [
          Measured::Length(1.874, :in),
          Measured::Length(3.906, :in),
          Measured::Length(5.811, :in)
        ]
      )
    end

    let(:package_two) do
      Physical::Package.new(
        id: "my_package_2",
        weight: Measured::Weight(5.928, :lbs),
        dimensions: [
          Measured::Length(2.843, :in),
          Measured::Length(5.193, :in),
          Measured::Length(6.912, :in)
        ]
      )
    end

    let(:options) do
      FriendlyShipping::Services::USPSShip::RateEstimateOptions.new(
        shipping_method: shipping_method,
        mailing_date: Date.parse("2024-04-03")
      )
    end

    context "with a valid request", vcr: { cassette_name: "usps_ship/rate_estimates/success" } do
      it { is_expected.to be_success }

      it "has all the right data" do
        result = rate_estimates.value!.data
        expect(result.length).to eq(1)
        rate_estimate = result.first
        expect(rate_estimate).to be_a(FriendlyShipping::Rate)
        expect(rate_estimate.total_amount).to eq(Money.new(2655, "USD"))
        expect(rate_estimate.shipping_method.name).to eq("USPS Ground Advantage")
        expect(rate_estimate.data[:description]).to eq("USPS Ground Advantage Machinable Dimensional Rectangular")
        expect(rate_estimate.data[:zone]).to eq("05")
      end
    end

    context "with an invalid destination zip code", vcr: { cassette_name: "usps_ship/rate_estimates/invalid_dest_zip" } do
      let(:destination) { FactoryBot.build(:physical_location, zip: "00000") }

      it { is_expected.to be_failure }

      it "has the correct error message" do
        expect(rate_estimates.failure.to_s).to eq("Could not find zone from provided ZIPs, date, and mail class")
      end
    end

    context "with a missing destination zip code", vcr: { cassette_name: "usps_ship/rate_estimates/missing_dest_zip" } do
      let(:destination) do
        Physical::Location.new(
          company_name: "Consignee Test 1",
          city: "Allanton",
          region: "MO",
          country: "US"
        )
      end

      it { is_expected.to be_failure }

      it "has the correct error message" do
        expect(rate_estimates.failure.to_s).to include(
          "OASValidation OpenAPI-Spec-Validation-Domestic-Prices with resource oas://domestic-prices-v3.yaml: " \
          "failed with reason: [ERROR - [Path '/destinationZIPCode'] Instance type (null) does not match any " \
          "allowed primitive type (allowed: [string]): []]"
        )
      end
    end

    context "with an invalid access token", vcr: { cassette_name: "usps_ship/rate_estimates/invalid_access_token" } do
      let(:access_token) do
        FriendlyShipping::Services::USPSShip::AccessToken.new(
          token_type: "Bearer",
          expires_in: 3599,
          raw_token: "WRONG_TOKEN"
        )
      end

      it { is_expected.to be_failure }
      it { expect(rate_estimates.failure.to_s).to eq("Missing or malformed access token.") }
    end
  end

  describe "#timings" do
    subject(:timings) { service.timings(shipment, options: options) }

    let(:shipment) { FactoryBot.build(:physical_shipment, packages: [], origin: origin, destination: destination) }
    let(:origin) { FactoryBot.build(:physical_location, region: "NC", zip: '27703') }
    let(:destination) { FactoryBot.build(:physical_location, region: "FL", zip: '32821') }

    let(:options) do
      FriendlyShipping::Services::USPSShip::TimingOptions.new(
        shipping_method: shipping_method,
        mailing_date: Date.parse("2024-04-03")
      )
    end

    context "with a valid request", vcr: { cassette_name: "usps_ship/timings/success" } do
      it { is_expected.to be_success }

      it "has all the right data" do
        result = timings.value!.data
        expect(result.length).to eq(2)
        timing = result.first
        expect(timing).to be_a(FriendlyShipping::Timing)
        expect(timing.pickup).to eq(Time.parse("2024-04-03 08:00"))
        expect(timing.delivery).to eq(Time.parse("2024-04-06 18:00"))
        expect(timing.guaranteed).to be(false)
        expect(timing.data).to eq(
          notes: "WEIGHT_LESS_THAN_1_POUND",
          service_standard: "3",
          service_standard_message: "3 Days"
        )
      end
    end

    context "with an invalid destination zip code", vcr: { cassette_name: "usps_ship/timings/invalid_dest_zip" } do
      let(:destination) { FactoryBot.build(:physical_location, zip: "00000") }

      it { is_expected.to be_failure }

      it "has the correct error message" do
        expect(timings.failure.to_s).to eq("No timings were returned. Is the destination zip correct?")
      end
    end

    context "with a missing destination zip code", vcr: { cassette_name: "usps_ship/timings/missing_dest_zip" } do
      let(:destination) do
        Physical::Location.new(
          company_name: "Consignee Test 1",
          city: "Allanton",
          region: "MO",
          country: "US"
        )
      end

      it { is_expected.to be_failure }

      it "has the correct error message" do
        expect(timings.failure.to_s).to include(
          "OASValidation OpenAPI-Spec-Validation-Service-Standards with resource oas://service-standards-3.0.0_swagger_resolved_non-flat.yaml: " \
          "failed with reason: [ERROR - Parameter 'destinationZIPCode' is required but " \
          "is missing.: []]"
        )
      end
    end

    context "with an invalid access token", vcr: { cassette_name: "usps_ship/timings/invalid_access_token" } do
      let(:access_token) do
        FriendlyShipping::Services::USPSShip::AccessToken.new(
          token_type: "Bearer",
          expires_in: 3599,
          raw_token: "WRONG_TOKEN"
        )
      end

      it { is_expected.to be_failure }
      it { expect(timings.failure.to_s).to eq("Missing or malformed access token.") }
    end
  end
end
