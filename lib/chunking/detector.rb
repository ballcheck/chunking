# TODO: should have colour_tolerance and non_colour_tolerance.
# TODO: @axis could be a class, thus preventing passing strings / syms around.
# TODO: method for traversing image - as_tree?
# TODO: rename Chunking
# TODO: detect_all_boundaries
# TODO: split_image method
# TODO: usage examples
# TODO: one off behavioural test for passing in image string / instance
require File.expand_path( "../detector_run.rb", __FILE__ )
require File.expand_path( "../boundary.rb", __FILE__ )

# Extracting blocks of content from an image using boundary detection.
# Applications includes extracting sections of text prior to ocr operations.
# Image traversal.
module Chunking

  class Detector
    attr_accessor :axis, :offset, :size, :colour, :fuzz, :density, :tolerance
    attr_reader :runs
    RGB_BLACK = [0,0,0]
    #-- TODO: are these max rgb values coupled to rmagick?
    ANNOTATE_DENSITY_REACHED = [ 65535, 0, 0, 0 ]
    ANNOTATE_PIXEL_IS_COLOUR = [ 0, 0, 65535 ]
    ANNOTATE_NIL = [ 40000, 40000, 40000 ]

    def initialize( args = {} )
      # "size" represents width OR height and "offset" represents
      # left or bottom depending on axis supplied 
      @axis = args.has_key?(:axis) ? args[:axis].to_sym : :x
      @offset = args.has_key?(:offset) ? args[:offset] : 0
      @size = args.has_key?(:size) ? args[:size] : Rational( 1 )
      @colour = args.has_key?(:colour) ? args[:colour] : RGB_BLACK
      @fuzz = args.has_key?(:fuzz) ? args[:fuzz] : 0
      # pixel "density", line "tolerance"
      @density = args.has_key?(:density) ? args[:density] : 1
      @tolerance = args.has_key?(:tolerance) ? args[:tolerance] : 0
      @runs = []
    end

    #:main:
    # Detects the next content boundary from a given starting position i.e.
    # the position where a block of content starts or finishes (depending on
    # whether the starting position was inside or outside a content block).
    def detect_boundary( image, start_index = 0, invert_direction = false, annotate = true )
      image = retrieve_image( image )

      # The default direction is left to right, top to bottom.
      # To go from right to left, or bottom to top we simply invert the image.
      image = image.invert( axis ) if invert_direction
      run = DetectorRun.new( self, image, start_index )
      runs << run

      lines = determine_remaining_lines( image, start_index )

      lines.to_i.times do |line|
        index = start_index + line
        run.state = detect_colour?( image, index, annotate )
        run.state_changed? ? run.increment_tolerance_counter : run.reset_tolerance_counter

        if run.tolerance_reached?
          run.boundary = Boundary.new( axis, index - tolerance )
          return run.boundary
        end
      end

      # un-invert the run image
      image.invert!( axis ) if invert_direction

      # we've run out of lines, so no boundary was detected in the image.
      return nil
    end

    # Skip n - 1 boundaries and return the nth.
    def detect_nth_boundary( image, n, start_index = 0, invert_direction = false, annotate = false )
      index = start_index
      boundary = nil
      n.times do
        boundary = detect_boundary( image, index, invert_direction, annotate )
        return nil unless boundary
        index = boundary.index
      end

      return boundary
    end

    # Tell if a given line within an image contains the Detector @colour.
    def detect_colour?( image, line_index = nil, annotate = false )
      line_index ||= 0
      pixel_count = 0
      offset = determine_offset( image )
      size = determine_size( image )
      fuzz = determine_fuzz( image )

      size.times do |ind|
        x = axis == :x ? ind + offset : line_index
        y = axis == :y ? image.size( axis ) - 1 - ( ind + offset ) : line_index

        if image.pixel_is_colour?( x, y, colour, fuzz )
          if density_reached?( pixel_count += 1, image )
            annotate_image( x, y, :density_reached ) if annotate
            return true
          else
            annotate_image( x, y, :pixel_is_colour ) if annotate
          end
        else
          annotate_image( x, y, nil ) if annotate
        end
      end

      return false
    end
    
    alias detect_color? detect_colour?

    def annotate_image( x, y, result )
      #-- TODO: untested
      image = runs.last.annotation_mask
      if result == :density_reached
        image.set_pixel_colour( x, y, ANNOTATE_DENSITY_REACHED )
      elsif result == :pixel_is_colour
        image.set_pixel_colour( x, y, ANNOTATE_PIXEL_IS_COLOUR )
      else
        image.set_pixel_colour( x, y, ANNOTATE_NIL )
      end
    end
        

    class << self
      # Class method version of instance method of the same name. Provided for simplicity.
      def detect_colour?( image, index = nil, *args )
        self.new( *args ).detect_colour?( image, index )
      end

      alias detect_color? detect_colour?
    end

    private 

    #-- TODO: start of untested methods
    def retrieve_image( image_path_or_instance )
      if image_path_or_instance.is_a?( String ) || image_path_or_instance.is_a?( Magick::Image )
        Image::RMagick.new( image_path_or_instance )
      else
        return image_path_or_instance
      end
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

  end
end
