module FriendlyShipping
  module Services
    class ShipEngine
      def initialize(token:)
        @token = token
      end

      private

      attr_reader :token
    end
  end
end
