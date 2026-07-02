# frozen_string_literal: true

module FriendlyShipping
  # A canonical catalog of the LTL (less-than-truckload) carriers that freight
  # brokers such as {Services::Reconex} rate-shop, keyed by SCAC (Standard
  # Carrier Alpha Code).
  #
  # Each entry is a {Carrier} whose first-class {Carrier#scac} is the carrier's
  # primary SCAC. Because a single carrier can report more than one SCAC (FedEx
  # Freight reports two: one for Priority and one for Economy), every SCAC the
  # carrier may report is listed in `data[:scacs]`. Lookups match against that
  # full list.
  #
  # `data[:tracking_url_template]` uses `:tracking` as the placeholder for the
  # PRO/tracking number, matching the convention used by tracking-code renderers.
  module LTLCarriers
    # All known LTL carriers, one entry per carrier.
    #
    # Carriers that friendly_shipping has a dedicated service for are referenced
    # from that service's canonical `CARRIER` constant, so they are defined in
    # exactly one place. The remaining carriers have no dedicated service and are
    # defined here.
    #
    # @return [Array<Carrier>]
    ALL = [
      Services::RL::CARRIER,
      Services::TForceFreight::CARRIER,
      Carrier.new(
        id: "saia",
        name: "SAIA",
        scac: "SAIA",
        data: {
          scacs: ["SAIA"],
          tracking_url_template: "https://www.saiasecure.com/tracing/n_manifest.asp?link=y&pro=:tracking"
        }
      ),
      Carrier.new(
        id: "fedex_freight",
        name: "FedEx Freight",
        scac: "FXFE",
        data: {
          scacs: ["FXFE", "FXNL"],
          tracking_url_template: "https://www.fedexfreight.com/fedextrack/?trknbr=:tracking"
        }
      ),
      Carrier.new(
        id: "southeastern_freight_lines",
        name: "Southeastern Freight Lines",
        scac: "SEFL",
        data: {
          scacs: ["SEFL"],
          tracking_url_template: "https://www.sefl.com/webconnect/tracing?Type=PN&RefNum1=:tracking"
        }
      ),
      Carrier.new(
        id: "xpo",
        name: "XPO",
        scac: "CNWY",
        data: {
          scacs: ["CNWY"],
          tracking_url_template: "https://ext-web.ltl-xpo.com/public-app/shipments?referenceNumber=:tracking"
        }
      )
    ].freeze

    class << self
      # @return [Array<Carrier>] all known LTL carriers
      def all
        ALL
      end

      # Finds the carrier that reports the given SCAC.
      #
      # @param scac [String, nil] a SCAC (case-insensitive)
      # @return [Carrier, nil] the matching carrier, or nil if none reports the SCAC
      def find_by_scac(scac)
        return nil if scac.nil?

        normalized = scac.upcase
        ALL.find { |carrier| carrier.data[:scacs].include?(normalized) }
      end

      # Builds a tracking URL for the given SCAC and PRO/tracking number.
      #
      # @param scac [String, nil] a SCAC (case-insensitive)
      # @param tracking [String] the PRO/tracking number
      # @return [String, nil] the tracking URL, or nil when the SCAC is unknown
      #   or the carrier has no tracking URL template
      def tracking_url_for(scac, tracking:)
        template = find_by_scac(scac)&.data&.[](:tracking_url_template)
        return nil if template.nil?

        template.gsub(":tracking", tracking.to_s)
      end
    end
  end
end
