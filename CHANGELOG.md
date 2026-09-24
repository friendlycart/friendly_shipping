# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
- TForce Freight: Add `cancel_pickup` to cancel a previously scheduled pickup by its confirmation number (`DELETE /pickup/request/{confirmationNumber}`). Returns a hash with the response status and transaction reference. Success/failure is determined from `responseStatus.code`.
- R+L: Add `cancel_pickup` to cancel a previously scheduled pickup by its pickup request number (`DELETE /PickupRequest`). Takes a required `reason:` (an `ArgumentError` is raised if it exceeds 100 characters). R+L returns no messages for a successful cancellation, and returns that same empty success for a pickup request number that doesn't exist, so a `Success` means the request was accepted rather than that a pickup was cancelled. Cancelling a pickup that is already cancelled is reported as an error: only pickups that are Unassigned, Assigned or Dispatched can be cancelled.
- R+L: Fix `ApiError` discarding the error message on any response that wasn't HTTP 400. R+L returns its error envelope for server errors too (cancelling a pickup in a non-cancellable status comes back as a 500), which previously surfaced as a bare `RestClient::ExceptionWithResponse` instead of the reason.
- TForce Freight: Fix `ApiError` message parsing when `responseStatus.description` is an object rather than a string. The Pickup API nests `errorCode` and `errorDescription` there, which previously leaked a stringified hash into the error message.
- `HttpClient#delete` now sends the request body as the payload, so carriers requiring a body on `DELETE` are supported.
- R+L: Require `base64` in the print BOL and print shipping label parsers. They referenced `Base64` without requiring it and only worked because another service happened to load it first.

## [0.10.5] - 2026-09-16
- TForce Freight: Include handling unit (pallet) dimensions in the create BOL request when they are available and are neither zero nor infinity.
- TForce Freight: Add a `density_eligible` flag to `BOLOptions`. When enabled, TForce rates the shipment on pallet density instead of NMFC code and freight class, which requires dimensions and weight for each pallet.
- TForce Freight: Fix the rates parser raising when a rate cannot be found and the currency comes back nil.
- Relax the `money` dependency from `~> 6.0` to `>= 6, < 8`.
- Add `FriendlyShipping::Services::Reconex`, a new freight service for the Reconex broker API: `rate_quote`, `create_load`, `get_load_info`, and `update_load` (used to dispatch a BOL), along with their options, serializer, parser, and result classes. The service accepts a single `api_base_url` and an optional `logger` for debug output.
- USPS Ship: Update the API base URL from `api.usps.com` to `apis.usps.com`.
- UPS (JSON): Rename SurePost shipping methods to Ground Saver, matching the UPS rebrand. The SurePost names remain as legacy aliases and the service codes (92-95) are unchanged.
- UPS (JSON): Surface the customs invoice (international forms) returned when `paperless_invoice: true` is set, on `UpsJson::Label#data`. It was previously dropped by the parser.
- UPS (JSON): Add UPS Worldwide Economy DDU (service code `17`) and DDP (service code `72`) as US-origin international shipping methods.
- `Carrier`: Add a first-class `scac` attribute (Standard Carrier Alpha Code).
- Add `FriendlyShipping::LTLCarriers`, a canonical catalog of the LTL carriers freight brokers (e.g. Reconex) rate-shop, keyed by SCAC. Each entry is a `Carrier` carrying its full list of SCACs (`data[:scacs]`) and a tracking-URL template. Provides `LTLCarriers.all`, `LTLCarriers.find_by_scac`, and `LTLCarriers.tracking_url_for`.
- R+L: Add a `CARRIER` constant (SCAC `RLCA`) and a `carriers` method returning it, matching the other freight services.
- TForce Freight: Add SCAC `UPGF` to the `CARRIER` constant.
- R+L: Add `BOLHandlingUnitsSerializer` and `handling_units_serializer` option on `BOLOptions`. When set, the create-BOL request sends `HandlingUnits` (with each structure's packages nested as `Items`) instead of the top-level `Items` array. `RL::StructureOptions` now accepts a `handling_unit:` symbol mapping to R+L unit type codes (PLT, SKD, BOX, TOTE, etc., default `:pallet`).
- R+L: Deprecate `structures_serializer` and the top-level `Items` output in favor of `handling_units_serializer`. The default will flip in a future release.
- TForce Freight: Add `get_documents` to retrieve documents (BOL, claims, delivery receipt, invoice, weight certificate) for an existing shipment by PRO number via the Documents API. Returns an array of `ShipmentDocument`. Categories are specified as friendly symbols (e.g. `:bill_of_lading`). Success/failure is determined from `summary.responseStatus.code` because the Documents API returns HTTP 200 even for errors.
- TForce Freight: Add the `:address_labels_2x3` label type (code `09`) to `DocumentOptions`, matching the current Shipping API manual.
- Reconex: Send `street2` (from `Physical::Location#address2`) for the billing, origin, and destination locations in the CreateLoad and UpdateLoad requests. Previously the second address line was dropped, so unit/suite numbers never reached the Reconex portal or the carrier's BOL.

## [0.10.4] - 2025-08-14
- Upgrade `physical` dependency to `~> 0.6`

## [0.10.3] - 2025
- Add USPS Ship city/state lookup request (#279)

## [0.10.2] - 2025
- Remove legacy UPS integration (#275)
- Add observer gem to Gemfile (#276)
- Remove legacy USPS integration (#277)
- Add UPS surcharge code 495 to money hash parser (#278)

## [0.10.1] - 2025-01-03
- Remove Inflections file (#274)

## [0.10.0] - 2025-01-03
- Bump version to 0.9.0 and log changes (#257)
- USPS Ship: Fix machinable criteria (#258)
- Add debug param to ShipEngine labels method (#259)
- Truncate R+L BOL address lines to 30 chars (#260)
- Fix UPS json rate details, add specs (#261)
- Fix ups label cost breakdown (#262)
- Remove TForce company name sanitization (#263)
- Update payload location of NegotiatedRatesIndicator within UPS JSON (#264)
- Attach cost breakdown to R+L rates data (#265)
- Expand TForce cost breakdown detail (#266)
- Never send empty UPS ShipmentRatingOptions (#267)
- Bump required Ruby version to 3.1 or greater (#269)
- Add city/state lookup endpoint for UPS JSON API (#268)
- Extract AccessToken parent class (#270)
- Return errors in ApiFailures for USPS timings, UPS json parsing (#271)
- Deprecate ApiFailure class (#272)
- Use Zeitwerk to load FriendlyShipping (#273)

## [0.9.0] - 2024-05-02
- Implement R&L service with rates and timings (#177)
- Add R&L Freight API call to create BOL and schedule pickup (#178)
- Add R&L Freight API calls to print BOL and shipping labels (#179)
- Add universal PRO option for R&L Freight (#180)
- Extract R&L Freight package serializer classes (#181)
- Refactor R+L BOL creation to return new `ShipmentInformation` object (#182)
- Add reference numbers to R+L BOL options class (#183)
- Add sub-version option to UPS rate/shipping requests (#184)
- Parse modifiers from UPS rates response XML (#185)
- R+L Shipping outside of Domestic USA & Canada requires dimensions (#187)
- Use R+L Carriers sandbox API for test mode (#188)
- Add optional pickup date to UPS rate requests (#189)
- Replace `BadRequestHandler` with `ApiErrorHandler` (#190)
- Update ShipEngine to support APC (#191)
- Rename `ShipmentInformation#number` (#196)
- Allow setting `ShipmentInformation#number` value (#197)
- Add declaration statement to UPS intl labels (#195)
- Add additional instructions to R+L BOL requests (#198)
- Add special instructions to R+L BOL requests (#199)
- Add TForce API rates endpoint (#194)
- Update physical gem to v0.5.1 (#200)
- Extract UPS Freight handling units generator class (#203)
- Fix options to allow option class args to actually override the default (#204)
- Add TForce endpoint to create access token (#206)
- Adjust TForce error parser for API errors (#208)
- Truncate zips to 5 digits for TForce (#210)
- Add comments to TForce rating call type codes (#207)
- Consolidate customs items for ShipEngine (#209)
- Add TForce pickup request service method (#211)
- Add TForce create BOL service method (#212)
- UPS json api rates and timings (#213)
- RL Invoice (#214)
- Add ups json api address classification api (#215)
- Stripe leading/trailing whitespace from R+L phone (#222)
- Update dotenv requirement from ~> 2.7 to ~> 3.0 (#223)
- Parse TForce shipment documents (#218)
- Ups json api labels (#221)
- ShipEngine address validation service method (#224)
- Fix ShipEngine address validation serializer (#225)
- Fix ShipEngine address validation return value (#227)
- Add timing details to ShipEngine rates (#226)
- Add additional response data to ShipEngine rates (#228)
- Exclude dimensions from ShipEngine rate estimates when zero (#229)
- Fix rates path and remove ignored attributes (#230)
- Add `comparison_rate_type` to ShipEngine rates requests (#231)
- Fix YARD docs for ShipEngine rates options (#232)
- Add YARD docs to R+L, ShipEngine, and TForce (#205)
- Rename TForce item/package options classes (#235)
- Remove periods from city names for R+L requests (#236)
- Use new `Physical::Structure` class for LTL/freight services (#201)
- Update TForce handling units class to use structures instead of packages (#238)
- Fix Poland's ISO code (#237)
- Remove duplicate package deprecation warnings (#239)
- Use UPS response header to determine errors (#240)
- Deprecate legacy First Class mail types (#242)
- Add reference numbers to packages (#243)
- Use error description when UPS returns bad json (#245)
- Add address validation query param (#241)
- Add city validation to UPS json label request (#246)
- TForce Freight: Parse pickup confirmation numbers (#248)
- Fix TForce shipping label codes (#249)
- TForce Freight: Fix parsing of BOL creation error responses (#250)
- Add `.env.test.local.template` file (#251)
- Add service class for new USPS Ship API (#244)
- Append request/response to USPS Ship API result (#253)
- Better error message on 400 from UPS json api (#254)
- Truncate long values in TForce API requests (#252)
- Escape special chars in TForce BOL API request (#255)
- Change USPS Ship package option default value (#256)

## [0.8.1] - 2023-08-03
- USPS Service: Fix international ounces remainder (#166)
- UPS Service: Fix bug causing inflated international product costs (#167)
- UPS Service: Add declared value to UPS package serializer (#168)
- UPS Service: Add declared value to UPS label package options (#169)
- TForce Service: Truncate long values in UPS Freight label request (#170)
- USPS Service: Add new USPS Ground Advantage shipping method (#171)
- ShipEngine Service: Basic ShipEngine LTL service class (#172)
- UPS Service: Add new billing options for Non-Resident Importer (#174)
- ShipEngine Service: Request quotes from ShipEngine LTL API (#175)

## [0.8.0] - 2023-04-18
- Rails 7 support: Fix deprecation warning about ActiveSupport#sum (#164)
- UPS Service: Truncate product descriptions (#163)
- TForce Service: Handle Timeouts gracefully (#162)
- UPS Service: Support per-item origin countries for paperless invoices (#161)
- USPS Service: Fix for currency formatting when shipping internationally (#160)
- ShipEngine Service: Add support for customs information (#159)
- UPS Service: Require both name and attention name for international shipping (#158)
- UPS Service: Allow third-party billing for taxes and fees (#156)
- USPS: New service for international shipping (#155)
- UPS Service: Parse missing package charges (#154)

## [0.7.3] - 2023-01-24
- UPS Service: Record USPS tracking code (#153)

## [0.7.2] - 2023-01-24
- ShipEngine Service: Allow sending a label image ID when creating labels (#152)

## [0.7.1] - 2023-01-20
- ShipEngine Service: Include package dimensions even if package code given

## [0.7.0] - 2022-12-14
- Removes dependency on unmaintained data_uri gem
- Bumps required Ruby to 2.7

## [0.6.5] - 2022-04-25

### Added
- USPS Service: Add support for returned dimensional weight (#128)
- USPS Service: Add support for returned fees (#127)

### Changed
- ShipEngine Service: Prevent exceptions when no rates are returned (#125)
- Misc dependency updates (#116, #120, #121, #124)

## [0.6.4] - 2021-01-27

### Added
- UPS Service: Include negotiated charges for UPS (#119)
- UPS Service: Include shipment-level itemized charges (#117)

## [0.6.3] - 2020-10-30

### Added
- USPS Service: Append HFP (Hold For Pickup) to service code when necessary (#110)
- USPS Service: Add Priority Cubic shipping method (#113)

### Changed
- USPS Service: Refactor to use explicit service codes (#111)
- USPS Service: Match Priority Express by CLASSID instead of service name (#112)
- UPS Service: Rename peak surcharge keys to match UPS docs (#114)

## [0.6.2] - 2020-08-12

- UPS Service: Be more resilient when UPS does not send a PickupTime element

## [0.6.1] - 2020-03-11

- Add Content-Type header to UPS Freight API requests, fixing "Name too long" 500 error responses

## [0.6.0] - 2020-03-11

- Changelog additions missed in previous release

## [0.5.3] - 2020-03-11

- UPS Service: Add support for shipping labels / bills of lading (#92)
- UPS/USPS Services: Return ApiFailure instead of a string for failed API responses (#95)
- UPS/USPS Services: Refactor ApiFailure to subclass ApiResponse (#96)

## [0.5.2] - 2020-01-31

### Added
- USPS Service: Added rectangular boolean to rate options class (#89)
- USPS Service: Added readable body to request class (#88)

### Removed
- USPS Service: Drop deprecated rectangular container (#89)

## [0.5.1] - 2020-01-28

### Changed
- USPS Service: Rename "Package Services" shipping method (#85)
- Documentation updates (#86)

## [0.5] - 2020-01-24

### Removed
- Drop support for Ruby 2.4 (#83)

### Changed
- UPS/USPS Services: Use options classes for rate estimates (#82)

## [0.4.14] - 2020-01-21

### Changed
- Code Style: Move development dependencies to Gemspec (#76)
- USPS Service: Fix documentation (#76)
- USPS Service: Use "Acceptance Date" if "Effective Acceptance Date" invalid (#79)

## [0.4.13] - 2020-01-18

### Changed
- USPS Service: Gracefully handle bogus responses from USPS (#77)

## [0.4.12] - 2020-01-15

### Changed
- USPS Service: Identify packages within a shipment by index rather than by ID (#74)

## [0.4.11] - 2020-01-14

### Changed
- USPS Service: Identify packages within a shipment by index rather than by ID (#72)
- USPS Service: Do not raise if multiple rates for a package and shipping method are present (#72)

## [0.4.10] - 2020-01-10

### Changed
- USPS Service: Gracefully handle missing timing estimates for Alaska/Hawaii (#70)

## [0.4.9] - 2020-01-09

### Changed
- USPS Service: Add missing Commitment sequence (#68)
- Code quality: Add double splats for Ruby 2.7 compatibility (#67)
- UPS Service: Add more package-level detail to rate responses (#65)

## [0.4.8] - 2020-01-06

### Changed
- USPS Service: Only transmit weights up to 150 pounds to timing API (#64)
- UPS Service: Transmit City and State when asking for timing information (#62)
- USPS Service: Gracefully handle missing expedited timing nodes (#60)

## [0.4.7] - 2019-11-28

### Changed
- UPS Service: Add timing support
- UPS Service: Add indicator for address type changes when quoting rates
- USPS Service: Add timing support
- Explicitly set Money rounding mode

## [0.4.6] - 2019-11-28

### Changed
- UPS Service: Add Support for voiding labels

## [0.4.5] - 2019-11-27

### Changed
- UPS Labels: Use correct Residential Address indication tag

## [0.4.4] - 2019-11-27

### Changed
- UPS Labels: Allow passing ShipperReleaseIndicator
- UPS Labels: Fix bug that did not allow reference numbers

## [0.4.3] - 2019-11-27

### Changed
- UPS Freight: Allow passing PickupRequest element with Pickup date

## [0.4.2] - 2019-11-19

### Changed
- UPS Freight: Pass TimeInTransitIndicator as a String rather than a Boolean

## [0.4.1] - 2019-11-15

### Changed
- Bugfix release: The file `types.rb`, which was accidentally put into `spec`, was moved to `lib`.

## [0.4.0] - 2019-11-11

### Added
- UPS Freight Service (rates estimation only for now)
- UPS: Label generation

### Changed

- All API methods now take a shipment, sometimes a typed Options object, and a `debug` flag.
- There are option classes for shipments, packages, and items. See the spec for UPS Freight about how they work.

### Changed
- Add ConsigneeName to Address validation/classification request

## [0.3.3] - 2019-10-25

### Changed
- Fix: ShipEngine#labels test mode works again.

## [0.3.2] - 2019-10-25

### Changed
- Fix: ShipEngine#labels now works as expected.

## [0.3.1] - 2019-06-20
### Added
- Endpoint for UPS address classification

### Changed
- `ShipEngine#labels` now needs a second argument, the shipping method.
