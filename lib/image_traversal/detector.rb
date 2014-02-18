require File.expand_path( "../detector_run.rb", __FILE__ )
require File.expand_path( "../detector_result.rb", __FILE__ )
require File.expand_path( "../boundary.rb", __FILE__ )
require File.expand_path( "../palette.rb", __FILE__ )

# Extracting blocks of content from an image using boundary detection.
# Applications includes extracting sections of text prior to ocr operations.
# Image traversal.
module ImageTraversal

  class Detector
    attr_accessor :axis, :offset, :size, :colour, :fuzz, :density, :tolerance
    attr_reader :runs

    def initialize( args = {} )
      # "size" represents width OR height and "offset" represents
      # left or bottom depending on axis supplied 
      @axis = args.has_key?(:axis) ? args[:axis].to_sym : :x
      @offset = args.has_key?(:offset) ? args[:offset] : 0
      @size = args.has_key?(:size) ? args[:size] : Rational( 1 )
      @colour = args.has_key?(:colour) ? args[:colour] : Palette.black
      @fuzz = args.has_key?(:fuzz) ? args[:fuzz] : 0
      # pixel "density", line "tolerance"
      @density = args.has_key?(:density) ? args[:density] : 1
      @tolerance = args.has_key?(:tolerance) ? args[:tolerance] : 0
      @runs = []
    end

    def image_adapter_class
      Image::AdapterMagickImage
    end

    #:main:
    # Detects the next content boundary from a given starting position i.e.
    # the position where a block of content starts or finishes (depending on
    # whether the starting position was inside or outside a content block).
    def detect_boundary( image, start_index = 0, invert_direction = false )
      # The default direction is left to right, top to bottom.
      # To go from right to left, or bottom to top, we invert_direction.
      runs << run = Detector::Run.new
      image = retrieve_image( image )
      last_line_index = image.size( axis_of_travel ) - 1

      lines = determine_remaining_lines( image, start_index )
      lines.to_i.times do |line|
        line_index = start_index + line
        absolute_line_index = invert_direction ? last_line_index - line_index : line_index
        result = detect_colour?( image, absolute_line_index )
        run.add_result( result )
        if run.tolerance_exceeded?( tolerance )
# TODO: if invert_direction is true, then this ends up having x,y coords relative to bottom (or right) edge. 
# consider boundary having 2 indexes. This will break behavioural tests.
          boundary_index = line_index - tolerance
          absolute_boundary_index = last_line_index - boundary_index
          return Boundary.new( axis, boundary_index, absolute_boundary_index )
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
      fuzz = determine_fuzz( image )

      result = Result.new
      pixel_count = 0

      size.times do |ind|
        x, y = determine_coords_from_params( axis, offset, ind, line_index, image )
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

    class << self
      # Class method version of instance method of the same name. Provided for simplicity.
      def detect_colour?( image, index = nil, *args )
        self.new( *args ).detect_colour?( image, index )
      end

      alias detect_color? detect_colour?
    end

    private 

    # start of untested methods
    # TODO: rename this method.
    def determine_coords_from_params( axis, offset, index, line_index, image )
      if axis == :x
        x = index + offset
        y = line_index
      elsif axis == :y
        x = line_index
        y = image.size( axis ) - 1 - ( index + offset )
      end
      [ x, y ]
    end

    def retrieve_image( image )
      image.is_a?( image_adapter_class ) ? image : image_adapter_class.factory( image )
    end

    def density_reached?( pixel_count, image = nil )
      density = determine_density( image )
      pixel_count >= density ? true : false
    end

    def determine_offset( image )
      offset_value = offset.is_a?( Rational ) ? image.size * offset.to_f : offset
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

    def determine_fuzz( image )
      fuzz_value = fuzz.is_a?( Rational ) ? image.quantum_range * fuzz.to_f : fuzz
      return fuzz_value.to_i
    end

    def axis_of_travel
      axis == :x ? :y : :x
    end
    
    def determine_remaining_lines( image, index )
      image.size( axis_of_travel ) - index.to_i
    end
    # end of untested.

  end
end
