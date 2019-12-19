# frozen_string_literal: true

require 'friendly_shipping/services/usps/parse_xml_response'
require 'friendly_shipping/timing'

module FriendlyShipping
  module Services
    class Usps
      class ParseTimeInTransitResponse
        class << self
          # Parse a response from USPS' time in transit API
          #
          # @param [FriendlyShipping::Request] request The request that was used to obtain this Response
          # @param [FriendlyShipping::Response] response The response that USPS returned
          # @return [Result<ApiResult<Array<FriendlyShipping::Timing>>>] When successfully parsing, an array of timings in a Success Monad.
          def call(request:, response:)
            # Filter out error responses and directly return a failure
            parsing_result = ParseXMLResponse.call(response.body, 'SDCGetLocationsResponse')
            parsing_result.fmap do |xml|
              expedited_commitments = xml.xpath('//Expedited')
              expedited_timings = parse_expedited_commitment_nodes(expedited_commitments)

              non_expedited_commitments = xml.xpath('//NonExpedited')
              non_expedited_timings = parse_non_expedited_commitment_nodes(non_expedited_commitments)

              ApiResult.new(
                expedited_timings + non_expedited_timings,
                original_request: request,
                original_response: response
              )
            end
          end

          private

          def parse_expedited_commitment_nodes(expedited_commitment_nodes)
            return [] if expedited_commitment_nodes.empty?

            # All Expedited Commitments have the same acceptance date
            effective_acceptance_date = Time.parse(expedited_commitment_nodes.at('EAD').text)
            expedited_commitment_nodes.xpath('Commitment').map do |commitment_node|
              shipping_method = SHIPPING_METHODS.detect do |potential_shipping_method|
                potential_shipping_method.name == MAIL_CLASSES[commitment_node.at('MailClass').text]
              end
              commitment_sequence = commitment_node.at('CommitmentSeq').text
              properties = COMMITMENT_SEQUENCES[commitment_sequence]
              scheduled_delivery_time = properties.delete(:commitment_time)
              scheduled_delivery_date = commitment_node.at('SDD').text
              parsed_delivery_time = Time.parse("#{scheduled_delivery_date} #{scheduled_delivery_time}")
              guaranteed = commitment_node.at('IsGuaranteed').text == '1'

              FriendlyShipping::Timing.new(
                shipping_method: shipping_method,
                pickup: effective_acceptance_date,
                delivery: parsed_delivery_time,
                guaranteed: guaranteed,
                properties: properties
              )
            end
          end

          def parse_non_expedited_commitment_nodes(non_expedited_commitment_nodes)
            non_expedited_commitment_nodes.map do |commitment_node|
              shipping_method = SHIPPING_METHODS.detect do |potential_shipping_method|
                potential_shipping_method.name == MAIL_CLASSES[commitment_node.at('MailClass').text]
              end
              # We cannot find a shipping method for Mail Classes 4 and 5 because USPS' docs are not clear
              next unless shipping_method

              properties = {
                commitment: commitment_node.at('SvcStdMsg').text,
                destination_type: NON_EXPEDITED_DESTINATION_TYPES[commitment_node.at('NonExpeditedDestType').text]
              }
              scheduled_delivery_date = commitment_node.at('SchedDlvryDate').text
              parsed_delivery_time = Time.parse(scheduled_delivery_date)
              effective_acceptance_date = Time.parse(commitment_node.at('EAD').text)

              FriendlyShipping::Timing.new(
                shipping_method: shipping_method,
                pickup: effective_acceptance_date,
                delivery: parsed_delivery_time,
                guaranteed: false,
                properties: properties
              )
            end.compact
          end

          # The USPS docs say the following:
          #
          # Valid Values:
          # “0” = All Mail Classes
          # “1” = Priority Mail Express
          # “2” = Priority Mail
          # “3” = First Class Mail
          # “4” = Marketing Mail
          # “5” = Periodicals
          # “6” = Package Services
          #
          # However, no shipping methods really map to "Marketing Mail" or "Periodicals".
          # This will likely be somewhat more work in the future.
          MAIL_CLASSES = {
            '1' => 'Priority Mail Express',
            '2' => 'Priority',
            '3' => 'First-Class',
            '6' => 'First-Class Package Service'
          }.freeze

          # This code carries a few details about the shipment:
          # - What USPS commits to (1-Day, 2-Day or 3-Day delivery)
          # - what time the package should arrive
          # - Whether the package is sent from post office to post office ('Hold For Pickup')
          # A0110 1-Day at 10:30 AM
          # B0110 1-Day at 10:30 AM HFPU
          # A0112 1-Day at 12:00 PM
          # A0115 1-Day at 3:00 PM
          # B0115 1-Day at 3:00 PM HFPU
          # A0210 2-Day at 10:30 AM
          # A0212 2-Day at 12:00 PM
          # A0215 2-Day at 3:00 PM
          # B0210 2-Day at 10:30 AM HFPU
          # B0215 2-Day at 3:00 PM HFPU
          # C0100 1-Day Street
          # C0200 2-Day Street
          # C0300 3-Day Street
          # D0100 1-Day PO Box
          # D0200 2-Day PO Box
          # D0300 3-Day PO Box
          # E0100 1-Day HFPU
          # E0200 2-Day HFPU
          # E0300 3-Day HFPU
          COMMITMENT_SEQUENCES = {
            'A0110' => {
              commitment: '1-Day',
              commitment_time: '10:30 AM',
            },
            'B0110' => {
              commitment: '1-Day',
              commitment_time: '10:30 AM',
              destination_type: :hold_for_pickup
            },
            'A0112' => {
              commitment: '1-Day',
              commitment_time: '12:00 PM',
            },
            'A0115' => {
              commitment: '1-Day',
              commitment_time: '3:00 PM',
            },
            'B0115' => {
              commitment: '1-Day',
              commitment_time: '3:00 PM',
              destination_type: :hold_for_pickup
            },
            'A0210' => {
              commitment: '2-Day',
              commitment_time: '10:30 AM',
            },
            'A0212' => {
              commitment: '2-Day',
              commitment_time: '12:00 PM',
            },
            'A0215' => {
              commitment: '2-Day',
              commitment_time: '3:00 PM',
            },
            'B0210' => {
              commitment: '2-Day',
              commitment_time: '10:30 AM',
              destination_type: :hold_for_pickup
            },
            'C0100' => {
              commitment: '1-Day',
              destination_type: :street
            },
            'C0200' => {
              commitment: '2-Day',
              destination_type: :street
            },
            'C0300' => {
              commitment: '3-Day',
              destination_type: :street
            },
            'D0100' => {
              commitment: '1-Day',
              destination_type: :po_box
            },
            'D0200' => {
              commitment: '2-Day',
              destination_type: :po_box
            },
            'D0300' => {
              commitment: '3-Day',
              destination_type: :po_box
            },
            'E0100' => {
              commitment: '1-Day',
              destination_type: :hold_for_pickup
            },
            'E0200' => {
              commitment: '2-Day',
              destination_type: :hold_for_pickup
            },
            'E0300' => {
              commitment: '3-Day',
              destination_type: :hold_for_pickup
            },
          }.freeze

          # Things are different for non-expedited shipping methods.
          NON_EXPEDITED_DESTINATION_TYPES = {
            '1' => :street,
            '2' => :po_box,
            '3' => :hold_for_pickup
          }.freeze
        end
      end
    end
  end
end
