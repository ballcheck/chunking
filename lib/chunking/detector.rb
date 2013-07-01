#--------------------------------------------------------------------
# chunking - breaking document up by identifying content boundaries
#--------------------------------------------------------------------

module Chunking

  class Detector
    attr_accessor :axis, :offset, :size, :rgb, :fuzz, :density, :tolerance
    RGB_BLACK = [0,0,0,0]

    # NOTE: "size" represents width OR height and "offset" represents top OR left depending on axis supplied 
    def initialize( args = {} )
      @axis = args.has_key?(:axis) ? args[:axis].to_sym : :x
      @offset = args.has_key?(:offset) ? args[:offset] : 0
      @size = args.has_key?(:size) ? args[:size] : nil
      @rgb = args.has_key?(:rgb) ? args[:rgb] : RGB_BLACK
      @fuzz = args.has_key?(:fuzz) ? args[:fuzz] : 0.2
      # pixel "density", line "tolerance"
      @density = args.has_key?(:density) ? args[:density] : 1
      @tolerance = args.has_key?(:tolerance) ? args[:tolerance] : 0
    end

    # TODO: untested
    def density_reached?( pixel_count, img = nil )
      density = determine_density( img )
      pixel_count >= density ? true : false
    end

    def determine_offset( img )
      is_percent_string?( offset ) ? apply_percent_string( img.size( axis ), offset ) : offset
    end
      
    def determine_size( img )
      is_percent_string?( size ) ? apply_percent_string( img.size( axis ), size ) : size
    end

    def determine_density( img )
      is_percent_string?( density ) ? apply_percent_string( determine_size( img ), density ) : density
    end

    # end of untested

    # TODO: annotate.
    def detect_boundary( img, start_index = 0, invert_direction = false )
      # default direction is left to right, top to bottom.
      img = img.invert( axis ) if invert_direction
      run = Detector::Run.new( self, img, start_index )

      lines = img.size( axis ) - start_index.to_i
      lines.times do |line|
        index = start_index + line
        run.state = detect_colour?( img, index )
        run.increment_tolerance_counter if run.state_changed?
        if run.tolerance_reached?( tolerance )
          run.boundary = Boundary.new( axis, index )
          return run
        end
      end

      # we've run out of image
      return nil
    end

    def detect_nth_boundary( img, n, start_index = 0, invert_direction = false )
      index = start_index
      n.times do
        index = detect_boundary( img, index, invert_direction )
        return nil unless index
      end

      return index
    end

    def detect_colour?( img, line_index = nil )
      line_index ||= 0
      pixel_count = 0
      offset = determine_offset( img )
      size = determine_size( img )

      size.times do |ind|
        x = axis == :x ? ind + offset : line_index
        y = axis == :y ? ind + offset : line_index
        
        if img.pixel_is_colour?( img, x, y, rgb, fuzz )
          if density_reached?( pixel_count += 1, img )
            return true
          end
        end
      end
      return false
    end
    
    alias detect_color? detect_colour?










    # TODO: instance versions of class methods not tested
    def is_percent_string?( *args )
      self.class.is_percent_string?( *args )
    end
    
    def apply_percent_string?( *args )
      self.class.apply_percent_string?( *args )
    end

    class << self
      def detect_colour?( img, index = nil, *args )
        self.new( *args ).detect_colour?( img, index )
      end

      alias detect_color? detect_colour?
    
      def is_percent_string?( string )
        string.is_a?( String ) && !!string.match(/(^[\d\.]+)%$/)
      end

      def apply_percent_string( number, string )
        number * ( string.to_f / 100 )
      end
    end
  end
end
