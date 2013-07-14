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
        colour_of_pixel = get_pixel_colour( x, y )

        colours.each do |colour|
          return true if self.class.compare_colours( colour, colour_of_pixel, fuzz )
        end

        return false
      end

      # template pattern style method declarations
      # TODO: enforce these methods are implemented in the child class
      # preferably called with the same arguments
      def self.compare_colours( *args )
        raise NotImplementedError
      end

      def size( *args )
        raise NotImplementedError
      end
        
      def get_pixel_colour( *args )
        raise NotImplementedError
      end

      def set_pixel_colour( *args )
        raise NotImplementedError
      end

      def invert( *args )
        raise NotImplementedError
      end

      # TODO: create colour / color aliases
      # aliases created here would refer to the template methods and raise.

      # only really used for testing.
      # TODO: untested
      def draw_pixel_map!( pixel_map )
        pixel_map.each_with_index do |row, row_ind|
          row.each_with_index do |px, px_ind|
            set_pixel_colour( px_ind, row_ind, px ) unless px.nil?
          end
        end
      end

      # TODO: untested
      class << self
        def new_from_pixel_map( pixel_map )
          rows = pixel_map.length
          cols = pixel_map[0].length
          img = self.new( cols, rows )
          img.draw_pixel_map!( pixel_map )
          return img
        end
      end

    end
  end
end
