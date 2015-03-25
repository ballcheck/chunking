module ImageTraversal

  class BoundaryLocator

    attr_reader :detector

    def initialize( detector )
      @detector = detector
    end

    # TODO: this method is doing too much, as you can see by the heavily stubbed tests
    def locate_boundary( image, start_index = 0, invert_direction = false )
      # The default direction is left to right, top to bottom.
      # To go from right to left, or bottom to top, we invert_direction.
      detector.runs << run = create_run

      image = retrieve_image( image )
      last_line_index = determine_last_line_index( image )

      # detect_colour on each line and add results to run.
      (start_index..last_line_index).each do |line_index|
        absolute_line_index = determine_absolute_line_index( invert_direction, last_line_index, line_index )
        result = detector.detect_colour?( image, absolute_line_index )
        run.add_result( result )

        # return boundary if present
        if boundary = determine_boundary( line_index, run )
          return boundary
        end
      end

      # we've run out of lines, so no boundary was detected in the image.
      return nil
    end

    private

    # TODO: badly named
    def determine_boundary( line_index, run )
      if tolerance_exceeded?( run.tolerance_counter )
        # the real boundary is where the tolerance_counter started.
        return Boundary.new( detector.axis, line_index - run.tolerance_counter + 1 )
      else
        return nil
      end
    end

    def tolerance_exceeded?( cnt )
      cnt > detector.tolerance
    end

    def determine_absolute_line_index( invert_direction, last_line_index, line_index )
      invert_direction ? last_line_index - line_index : line_index
    end

    def determine_last_line_index( image )
      image.size( axis_of_travel ) - 1
    end

    def axis_of_travel
      case detector.axis
      when :x
        :y
      when :y
        :x
      end
    end

    def create_run
      Detector::Run.new
    end

    def retrieve_image( image )
      image.is_a?( ImageTraversal.image_adapter_class ) ? image : ImageTraversal.image_adapter_class.factory( image )
    end

  end
end
