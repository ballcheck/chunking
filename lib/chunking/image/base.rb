# TODO: Whole module untested.
module Chunking
  module Image
    class Base
      attr_reader :base_image

      def initialize( base_image )
        @base_image = base_image
      end

      def pixel_is_colour?( x, y, rgb, fuzz )
        # expects "rgb" to be an array - [r,g,b] / [r,g,b,a]
        colours = rgb[0].is_a?( Array ) ? rgb :  [rgb]
        colour_of_pixel = pixel_colour( x, y )

        colours.each do |colour|
          return true if self.class.compare_colours( colour, colour_of_pixel, fuzz )
        end

        return false
      end

      # template pattern style method declarations
      # TODO: enforce these methods are implemented in the child class
      def self.compare_colours( *args )
        raise NotImplementedError
      end

      def size( *args )
        raise NotImplementedError
      end
        
      def pixel_colour( *args )
        raise NotImplementedError
      end

      def invert( *args )
        raise NotImplementedError
      end

      # TODO: create colour / color aliases
      # aliases created here would refer to the template methods and raise.
    end
  end
end
