module ImageTraversal

  class Detector
    class Result
      attr_reader :colour_state

      def initialize( colour_state )
        @colour_state = colour_state
      end

      def colour_detected?
        !!@colour_state
      end
    end
  end
end
