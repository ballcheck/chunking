module Chunking
  module Image

    module PixelColour
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Check equality of 2 colour values.
        # A custom method was needed because Magick::Pixel.fcmp method was very slow.
        # In benchmark tests (this processor only) the new method is faster by a factor of 10. See benchmark for 100000 pixels -
        #                    user       system     total      real
        #  fcmp              2.240000   0.270000   2.510000   (2.516855)
        #  compare_colours?  0.240000   0.000000   0.240000   (0.241203)
        def compare_colours?( a, b, fuzz = 0 )
          # Expects a and b to be arrays of numerical colour values - [r,g,b] / [r,g,b,a] / [c,m,y] / [c,m,y,k]
          # Only compare values at indexes present in BOTH colours, so [r,g,b] equals [r,g,b,a]
          last_index = [ a.length, b.length ].min - 1
          index_range = ( 0..last_index )

          index_range.each do |i|
            return false unless compare_single_colours?( a[i], b[i], fuzz )
          end

          return true
        end

        def compare_single_colours?( a, b, fuzz = 0 )
          ( a - b ).abs <= fuzz
        end
      end

      # Tell if the pixel and a given set of coordinates is the given colour.
      def pixel_is_colour?( x, y, colours, fuzz = 0 )
        colours = [colours] unless colours.is_a?( Array ) && colours.first.is_a?( Array )
        colour_of_pixel = get_pixel_colour( x, y )

        colours.each do |colour|
          return true if self.class.compare_colours?( colour, colour_of_pixel, fuzz )
        end

        return false
      end

      alias pixel_is_color? pixel_is_colour?

      # Draw an Image from an array (map) of pixels (only really used in testing).
      def draw_pixel_map!( pixel_map )
        pixel_map.each_with_index do |row, row_ind|
          row.each_with_index do |px, px_ind|
            set_pixel_colour( px_ind, row_ind, px ) unless px.nil?
          end
        end
        return self
      end

    end
  end
end
