module Chunking
  class Detector
    class Run
      attr_accessor :state, :image, :start_index, :boundary
      attr_reader :initial_state, :tolerance_counter, :detector

      def initialize( detector, image, start_index = 0 )
        @detector = detector
        @image = image
        @start_index = start_index
        @initial_state = self.class.determine_initial_state( @detector, @image, @start_index )
        @state = @initial_state
        @tolerance_counter = 0
      end

      def increment_tolerance_counter
        @tolerance_counter += 1
      end

      def state_changed?
        initial_state != state
      end

      def tolerance_reached?( tolerance )
        tolerance_counter.to_i > tolerance.to_i
      end
      
      # TODO: untested
      def annotate( image = self.image )
        
      end

      private

      # this is only here so it can be stubbed
      # TODO: this is only a class method because I was not sure how to access it from initialize & stub
      def self.determine_initial_state( detector, image, start_index )
        detector.detect_colour?( image, start_index )
      end

    end
  end
end
