require File.expand_path( "../detector_run.rb", __FILE__ )
require File.expand_path( "../detector_result.rb", __FILE__ )
require File.expand_path( "../boundary.rb", __FILE__ )
require File.expand_path( "../palette.rb", __FILE__ )

# Extracting blocks of content from an image using boundary detection.
# Image traversal.
module ImageTraversal

  class Detector
    attr_accessor :axis, :offset, :size, :colour, :fuzz, :density, :tolerance
    attr_reader :runs

    def self.factory( args = {} )
      axis = args.has_key?(:axis) ? args[:axis] : :x
      offset = args.has_key?(:offset) ? args[:offset] : 0
      size = args.has_key?(:size) ? args[:size] : Rational( 1 )
      colour = args.has_key?(:colour) ? args[:colour] : Palette.black
      fuzz = args.has_key?(:fuzz) ? args[:fuzz] : 0
      density = args.has_key?(:density) ? args[:density] : 1
      tolerance = args.has_key?(:tolerance) ? args[:tolerance] : 0

      return self.new( axis, offset, size, colour, fuzz, density, tolerance )
    end

    def initialize( axis, offset, size, colour, fuzz, density, tolerance )
      # "size" represents width OR height and "offset" represents
      # left or bottom depending on axis supplied 
      @axis = axis
      @offset = offset
      @size = size
      @colour = colour
      @fuzz = fuzz
      @density = density # pixel density
      @tolerance = tolerance # line tolerance
      @runs = []
    end

    #:main:
    # Detects the next content boundary from a given starting position i.e.
    # the position where a block of content starts or finishes (depending on
    # whether the starting position was inside or outside a content block).
    # TODO: consider moving this whole logic into Run. It makes some sense.
    def detect_boundary( image, start_index = 0, invert_direction = false )
      # The default direction is left to right, top to bottom.
      # To go from right to left, or bottom to top, we invert_direction.
      runs << run = create_run

      image = retrieve_image( image )
      last_line_index = determine_last_line_index( image )

      # detect_colour on each line and add results to run.
      (start_index..last_line_index).each do |line_index|
        absolute_line_index = determine_absolute_line_index( invert_direction, last_line_index, line_index )
        result = detect_colour?( image, absolute_line_index )
        run.add_result( result )

        # return boundary if present
        if boundary = determine_boundary( line_index, run )
          return boundary
        end
      end

      # we've run out of lines, so no boundary was detected in the image.
      return nil
    end

    # Skip n - 1 boundaries and return the nth.
    def detect_nth_boundary( image, n, start_index = 0, invert_direction = false )
      index = start_index
      boundary = nil
      n.times do
        boundary = detect_boundary( image, index, invert_direction )
        return nil unless boundary
        index = boundary.index
      end

      return boundary
    end

    # TODO: this method needs testing. Also it is possibly doing too much.
    # Tell if a given line within an image contains the Detector @colour.
    def detect_colour?( image, line_index = nil )
      line_index ||= 0

      offset = determine_offset( image )
      size = determine_size( image )
      fuzz = determine_fuzz

      image_size = image.size( axis )

      result = Result.new
      pixel_count = 0

      size.times do |ind|
        x, y = determine_pixel_coords( offset, ind, line_index, image_size  )
        colour_state = image.pixel_is_colour?( x, y, colour, fuzz )
        result.add_pixel( x, y, colour_state )

        if colour_state
          pixel_count += 1
          if density_reached?( pixel_count, image )
            result.set_colour_state( true )
            break
          end
        end

      end

      return result
    end
    
    alias detect_color? detect_colour?

    private 

    def determine_pixel_coords( offset, index, line_index, image_size )
      if axis == :x
        x = index + offset
        y = line_index
      elsif axis == :y
        x = line_index
        y = image_size - 1 - ( index + offset )
      end
      [ x, y ]
    end
    
    def determine_last_line_index( image )
      image.size( axis_of_travel ) - 1
    end

    def determine_absolute_line_index( invert_direction, last_line_index, line_index )
      absolute_line_index = invert_direction ? last_line_index - line_index : line_index
      absolute_line_index
    end

    def density_reached?( pixel_count, image = nil )
      density = determine_density( image )
      pixel_count >= density ? true : false
    end

    def determine_boundary( line_index, run )
      if tolerance_exceeded?( run.tolerance_counter )
        # the real boundary is where the tolerance_counter started.
        return Boundary.new( axis, line_index - run.tolerance_counter + 1 )
      else
        return nil
      end
    end

    def retrieve_image( image )
      image.is_a?( ImageTraversal.image_adapter_class ) ? image : ImageTraversal.image_adapter_class.factory( image )
    end

    def tolerance_exceeded?( cnt )
      cnt > tolerance
    end

    def determine_offset( image )
      offset_value = offset.is_a?( Rational ) ? image.size( axis ) * offset.to_f : offset
      return offset_value.to_i
    end
      
    def determine_size( image )
      size_value = size.is_a?( Rational ) ? image.size( axis ) * size.to_f : size
      return size_value.to_i
    end

    def determine_density( image )
      density_value = density.is_a?( Rational ) ? determine_size( image ) * density.to_f : density
      return density_value.to_i
    end

    def determine_fuzz
      fuzz_value = fuzz.is_a?( Rational ) ? Palette.max_colour_value * fuzz.to_f : fuzz
      return fuzz_value.to_i
    end

    def axis_of_travel
      case axis
      when :x
        :y
      when :y
        :x
      end
    end

    def create_run
      Detector::Run.new
    end

  end
end
