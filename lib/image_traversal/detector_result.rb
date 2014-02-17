module ImageTraversal

  class Detector
    
    class Result
      attr_reader :pixels

      def initialize( colour_state = false )
        @colour_state = colour_state
        @pixels = PixelCollection.new
      end

      def colour_detected?
        !!@colour_state
      end

      def set_colour_state( colour_state )
        @colour_state = colour_state
        self
      end

      def add_pixel( x, y, colour_state )
        pixels.push( Pixel.new( x, y, colour_state ) )
        self
      end
        
      # Annotate supplied image (one row)
      def annotate!( image )
        pixels.each do |pixel|
          colour_state = pixel.colour_state
          density_state = colour_detected? && pixel.equal?( pixels.last )
          annotation_colour = determine_annotation_colour( colour_state, density_state )
          image.set_colour( pixel.x, pixel.y, annotation_colour )
        end
      end

      private

      def determine_annotation_colour( colour_state, density_state )
        density_state ? Palette.annotate_density_reached : colour_state ? Palette.annotate_pixel_is_colour : Palette.annotate_nil
      end

      class Pixel
        attr_reader :x, :y, :colour_state

        def initialize( x, y, colour_state )
          @x = x
          @y = y
          @colour_state = colour_state
        end

        def coords
          [ @x, @y ]
        end

      end

      class PixelCollection < Array
      end
    end
  end
end
