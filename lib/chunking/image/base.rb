module Chunking
  # A wrapper-module providing library-agnostic image handling so we are not coupled with one library e.g. RMagick
  module Image
    # The base class from which Image classes should decend.
    class Base
      attr_reader :base_image

      # Check equality of 2 colour values.
      # A custom method was needed because Magick::Pixel.fcmp method was very slow.
      # In benchmark tests (this processor only) the new method is faster by a factor of 10. See benchmark for 100000 pixels -
      #                    user       system     total      real
      #  fcmp              2.240000   0.270000   2.510000   (2.516855)
      #  compare_colours?  0.240000   0.000000   0.240000   (0.241203)
      def self.compare_colours?( colour1, colour2, fuzz = 0 )
        # Expects colour to be an array of colour values - [r,g,b] / [r,g,b,a] / [c,m,y] / [c,m,y,k]
        # Only compares values that are present in BOTH colours
        cnt = [ colour1.length, colour2.length ].min
        cnt.times do |i|
          return false if ( colour1[ i - 1 ] - colour2[ i - 1 ] ).abs > fuzz
        end
        return true
      end

      # Tell if the pixel and a given set of coordinates is the given colour.
      def pixel_is_colour?( x, y, colour, fuzz )
        colours = colour[0].is_a?( Array ) ? colour :  [colour]
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
