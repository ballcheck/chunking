module ImageTraversal
  # Container used in Detector.detect_boundary to monitor detection progress and hold results.
  class Detector
    class Run
      attr_reader :results

      def initialize
        @results = []
        @tolerance_counter = 0
      end

      def add_result( result )
        results.push( result )

        if results.first && results.first.colour_detected? != result.colour_detected?
          increment_tolerance_counter
        else
          reset_tolerance_counter
        end
      end

      def tolerance_exceeded?( tolerance )
        @tolerance_counter > tolerance
      end

      private

      def increment_tolerance_counter
        @tolerance_counter += 1
      end

      def reset_tolerance_counter
        @tolerance_counter = 0
      end

    end
  end
end
