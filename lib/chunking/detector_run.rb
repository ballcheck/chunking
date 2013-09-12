module Chunking
  # Container used in Detector.detect_boundary to monitor detection progress and hold results.
  class DetectorRun
    attr_accessor :state, :boundary
    attr_reader :image, :start_index, :initial_state, :tolerance_counter, :detector, :annotation_mask

    def initialize( detector, image, start_index = 0 ) #:nodoc:
      @detector = detector
      @image = image
      @annotation_mask = create_annotation_mask
      @start_index = start_index
      @initial_state = determine_initial_state( @detector, @image, @start_index )
      @state = @initial_state
      @tolerance_counter = 0
    end

    def increment_tolerance_counter
      @tolerance_counter += 1
    end

    def reset_tolerance_counter
      @tolerance_counter = 0
    end

    # Whether the state changed since initialisation.
    def state_changed?
      initial_state != state
    end

    # Whether the maximum number of detected rows has been exceeded.
    def tolerance_reached?
      tolerance_counter.to_i > tolerance.to_i
    end

    # Apply the annotation_mask to the base_image. Visual representation of the DetectorRun useful in debugging.
    def annotate
      #-- TODO: untested.
      new_filename = "#{image.file_path}.annotated"
      new_image = image.annotate( annotation_mask, 0.95 )
      new_image.write( new_filename )
      return new_image
    end
      
    private

    def tolerance
      detector.tolerance
    end

    def create_annotation_mask
      #-- TODO: untested
      image.create_mask unless image.nil?
    end

    def determine_initial_state( detector, image, start_index )
      detector.detect_colour?( image, start_index )
    end

  end
end
