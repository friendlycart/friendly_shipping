# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FriendlyShipping::Services::USPSShip do
  subject(:service) { described_class.new(access_token: access_token) }

  let(:access_token) do
    FriendlyShipping::Services::USPSShip::AccessToken.new(
      token_type: "Bearer",
      expires_in: 3599,
      raw_token: ENV.fetch('ACCESS_TOKEN', nil)
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
    subject(:rate_estimates) { service.rate_estimates(shipment, options: options, debug: true) }

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

    let(:packages) { [package_1, package_2] }

    let(:package_1) do
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

    let(:package_2) do
      Physical::Package.new(
        id: "my_package_2",
        weight: Measured::Weight(42.67, :lbs),
        dimensions: [
          Measured::Length(18.86, :in),
          Measured::Length(17.72, :in),
          Measured::Length(13.66, :in)
        ]
      )
    end

    let(:package_1_options) do
      FriendlyShipping::Services::USPSShip::RateEstimatePackageOptions.new(
        package_id: "my_package_1",
        processing_category: :non_machinable
      )
    end

    let(:package_2_options) do
      FriendlyShipping::Services::USPSShip::RateEstimatePackageOptions.new(
        package_id: "my_package_2",
        processing_category: :machinable
      )
    end

    let(:options) do
      FriendlyShipping::Services::USPSShip::RateEstimateOptions.new(
        shipping_method: shipping_method,
        mailing_date: Date.parse("2024-04-10"),
        package_options: [package_1_options, package_2_options]
      )
    end

    context "with a valid request", vcr: { cassette_name: "usps_ship/rate_estimates/success" } do
      it { is_expected.to be_success }

      it "has all the right data" do
        rates = rate_estimates.value!.data
        expect(rates.length).to eq(1)

        rate = rates.first
        expect(rate).to be_a(FriendlyShipping::Rate)
        expect(rate.total_amount).to eq(Money.new(11_585, "USD"))
        expect(rate.amounts).to eq(
          price: Money.new(9785, "USD"),
          "Nonstandard Volume > 2 cu ft" => Money.new(1800, "USD")
        )
        expect(rate.shipping_method.name).to eq("USPS Ground Advantage")
        expect(rate.data[:description]).to eq("USPS Ground Advantage Nonmachinable Dimensional Rectangular")
        expect(rate.data[:zone]).to eq("05")
      end

      it "attaches request and response to API result" do
        api_result = rate_estimates.value!
        expect(api_result.original_request).to be_a(FriendlyShipping::Request)
        expect(api_result.original_response).to be_a(FriendlyShipping::Response)
      end
    end

    context "when the second package's request fails", vcr: { cassette_name: "usps_ship/rate_estimates/second_package_fails" } do
      let(:package_2_options) do
        FriendlyShipping::Services::USPSShip::RateEstimatePackageOptions.new(
          package_id: "my_package_2",
          processing_category: :letters # invalid processing category for this package
        )
      end

      it { is_expected.to be_failure }

      it "has the correct error message" do
        expect(rate_estimates.failure.to_s).to eq("Provided dimensions exceed maximum allowed for First Class Letters.")
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
        mailing_date: Date.parse("2024-04-10")
      )
    end

    context "with a valid request", vcr: { cassette_name: "usps_ship/timings/success" } do
      it { is_expected.to be_success }

      it "has all the right data" do
        result = timings.value!.data
        expect(result.length).to eq(2)
        timing = result.first
        expect(timing).to be_a(FriendlyShipping::Timing)
        expect(timing.pickup).to eq(Time.parse("2024-04-10 08:00"))
        expect(timing.delivery).to eq(Time.parse("2024-04-13 18:00"))
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

  describe "#city_state" do
    subject(:city_state) { service.city_state(location) }
    let(:location) { FactoryBot.build(:physical_location, region: "NC", zip: "27703") }

    context "with a valid request", vcr: { cassette_name: "usps_ship/city_state/success" } do
      it { is_expected.to be_success }

      it "has all the right data" do
        result = city_state.value!.data
        expect(result).to be_a(Physical::Location)
        expect(result.city).to eq("DURHAM")
        expect(result.region).to eq(Carmen::Country.coded("USA").subregions.coded("NC"))
        expect(result.zip).to eq("27703")
        expect(result.country).to eq(Carmen::Country.coded("USA"))
      end
    end

    context "with an invalid zip code", vcr: { cassette_name: "usps_ship/city_state/invalid_zip" } do
      let(:location) { FactoryBot.build(:physical_location, zip: "00000") }

      it { is_expected.to be_failure }

      it "has the correct error message" do
        expect(city_state.failure.to_s).to eq("Invalid Zip Code.")
      end
    end

    context "with a missing zip code", vcr: { cassette_name: "usps_ship/city_state/missing_zip" } do
      let(:location) do
        Physical::Location.new(
          city: "Allanton",
          region: "MO",
          country: "US"
        )
      end

      it { is_expected.to be_failure }

      it "has the correct error message" do
        expect(city_state.failure.to_s).to include(
          "OASValidation OpenAPI-Spec-Validation-Addresses-Request with resource oas://addresses_v3.yaml: " \
          "failed with reason: [ERROR - Parameter 'ZIPCode' is required but is missing.: []]"
        )
      end
    end

    context "with an invalid access token", vcr: { cassette_name: "usps_ship/city_state/invalid_access_token" } do
      let(:access_token) do
        FriendlyShipping::Services::USPSShip::AccessToken.new(
          token_type: "Bearer",
          expires_in: 3599,
          raw_token: "WRONG_TOKEN"
        )
      end

      it { is_expected.to be_failure }
      it { expect(city_state.failure.to_s).to eq("Missing or malformed access token.") }
    end
  end
end
