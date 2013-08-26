# TODO: benchmark & performance
# TODO: annotate.
# TODO: should have colour_tolerance and non_colour_tolerance.
# TODO: detector could have many runs.
# TODO: @axis could be a class, thus preventing passing strings / syms around.
# TODO: surely you don't need to require files in the same module?
require File.expand_path( "../detector_run.rb", __FILE__ )
require File.expand_path( "../boundary.rb", __FILE__ )

# Chunking - extracting blocks of content from an image by identifying content boundaries.
module Chunking

  class Detector
    attr_accessor :axis, :offset, :size, :colour, :fuzz, :density, :tolerance
    attr_reader :runs
    RGB_BLACK = [0,0,0]

    def initialize( args = {} )
      # "size" represents width OR height and "offset" represents
      # left or bottom depending on axis supplied 
      @axis = args.has_key?(:axis) ? args[:axis].to_sym : :x
      @offset = args.has_key?(:offset) ? args[:offset] : 0
      @size = args.has_key?(:size) ? args[:size] : nil
      @colour = args.has_key?(:colour) ? args[:colour] : RGB_BLACK
      @fuzz = args.has_key?(:fuzz) ? args[:fuzz] : 0.2
      # pixel "density", line "tolerance"
      @density = args.has_key?(:density) ? args[:density] : 1
      @tolerance = args.has_key?(:tolerance) ? args[:tolerance] : 0
      @runs = []
    end

    #:main:
    # Detects the next content boundary from a given starting position i.e.
    # the position where a block of content starts or finishes (depending on
    # whether the starting position was inside or ouside a content block).
    def detect_boundary( img, start_index = 0, invert_direction = false )
      # The default direction is left to right, top to bottom.
      # To go from right to left, or bottom to top we simply invert the image.
      img = img.invert( axis ) if invert_direction
      runs << ( run = DetectorRun.new( self, img, start_index ) )

      lines = determine_remaining_lines( img, start_index )

      lines.times do |line|
        index = start_index + line
        run.state = detect_colour?( img, index )
        run.state_changed? ? run.increment_tolerance_counter : run.reset_tolerance_counter

        # TODO: is run too closely tied now?
        if run.tolerance_reached?
          run.boundary = Boundary.new( axis, index - tolerance )
          return run.boundary
        end
      end

      # we've run out of lines, so no boundary was detected in the image.
      return nil
    end

    # Skip n - 1 boundaries and return the nth.
    def detect_nth_boundary( img, n, start_index = 0, invert_direction = false )
      index = start_index
      n.times do
        index = detect_boundary( img, index, invert_direction )
        return nil unless index
      end

      return index
    end

    # Tell if a given line within an image contains the Detector @colour.
    def detect_colour?( img, line_index = nil )
      # TODO: would it be cleaner to ignore the axis and just rotate the image? Performance issues?
      line_index ||= 0
      pixel_count = 0
      offset = determine_offset( img )
      size = determine_size( img )

      size.times do |ind|
        x = axis == :x ? ind + offset : line_index
        y = axis == :y ? img.size( axis ) - 1 - ( ind + offset ) : line_index

        if img.pixel_is_colour?( x, y, colour, fuzz )
          if density_reached?( pixel_count += 1, img )
            return true
          end
        end
      end
      return false
    end
    
    alias detect_color? detect_colour?

    class << self
      # Class method version of instance method of the same name. Provided for simplicity.
      def detect_colour?( img, index = nil, *args )
        self.new( *args ).detect_colour?( img, index )
      end

      alias detect_color? detect_colour?
    end

    private 

    #-- TODO: start of untested methods
    def density_reached?( pixel_count, img = nil )
      density = determine_density( img )
      pixel_count >= density ? true : false
    end

    def determine_offset( img )
      offset_value = is_percent_string?( offset ) ? apply_percent_string( img.size( axis ), offset ) : offset
      return offset_value.to_i
    end
      
    def determine_size( img )
      size_value = is_percent_string?( size ) ? apply_percent_string( img.size( axis ), size ) : size
      return size_value.to_i
    end

    def determine_density( img )
      density_value = is_percent_string?( density ) ? apply_percent_string( determine_size( img ), density ) : density
      return density_value.to_i
    end

    def axis_of_travel
      axis == :x ? :y : :x
    end
    
    def determine_remaining_lines( img, index )
      img.size( axis_of_travel ) - index.to_i
    end

    def is_percent_string?( *args )
      # TODO: instance versions of class methods not tested
      self.class.is_percent_string?( *args )
    end
    
    def apply_percent_string( *args )
      self.class.apply_percent_string( *args )
    end
    #-- end of untested methods

    class << self
      def is_percent_string?( string )
        string.is_a?( String ) && !!string.match(/(^[\d\.]+)%$/)
      end

      def apply_percent_string( number, string )
        number * ( string.to_f / 100 )
      end
    end
  end
end
