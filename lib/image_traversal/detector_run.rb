require File.expand_path( "../detector_run_result_collection.rb", __FILE__ )

module ImageTraversal
  # Container used in Detector.detect_boundary to monitor detection progress and hold results.
  class Detector
    class Run
      attr_reader :results, :tolerance_counter

      def initialize
        @results = ResultCollection.new
        @tolerance_counter = 0
      end

      def add_result( result )
        results << result

        if results.first.colour_detected? != result.colour_detected?
          # the state has changed since the first result
          increment_tolerance_counter
        else
          reset_tolerance_counter
        end
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
