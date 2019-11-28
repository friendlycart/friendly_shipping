# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
