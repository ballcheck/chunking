module ImageTraversal
  # Container used in Detector.detect_boundary to monitor detection progress and hold results.
  class Detector
    class Run
      attr_reader :results

      def initialize
        @results = ResultsCollection.new
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

      # Annotate supplied image with results
      def annotate( image, opacity = 0.5 )
        mask = image.create_mask

        # draw results on mask
        results.each do |result|
          result.annotate!( mask )
        end

        image.apply_mask( mask, opacity )
      end

      private

      def increment_tolerance_counter
        @tolerance_counter += 1
      end

      def reset_tolerance_counter
        @tolerance_counter = 0
      end

      class ResultsCollection < Array
      end

    end
  end
end
