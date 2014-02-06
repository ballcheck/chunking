require File.expand_path( "../pixel_colour.rb", __FILE__ )
require File.expand_path( "../masking.rb", __FILE__ )
require "RMagick"

module Chunking
  module Image
    # TODO: coupled to rmagick.
    BLACK_RGB = [ 0, 0, 0 ]
    WHITE_RGB = [ Magick::QuantumRange, Magick::QuantumRange, Magick::QuantumRange ]

    # Adapter class providing loose-coupling with RMagick
    class AdapterMagickImage
      include PixelColour
      include Masking
      attr_reader :base_image

      # TODO: don't think the factory should be in the adapter.
      class << self
        def factory( *args, &block )
          arg = args[0]

          if arg.is_a?( Magick::Image )
            self.new( arg )
          elsif arg.is_a?( String )
            # assume it's a file path
            self.new( Magick::Image.read( arg ).first )
          elsif arg.is_a?( Array )
            # assume it's a pixel map
            magick_image = Magick::Image.new( arg[0].length, arg.length )
            self.new( magick_image ).draw_pixel_map!( arg )
          else
            # give the lib a chance
            self.new( Magick::Image.new( *args, &block ) )
          end
        end

        def max_colour_value
          Magick::QuantumRange
        end
      end

      def initialize( base_image )
        @base_image = base_image
      end

      # Determine the size of the image on the given axis.
      def size( axis )
        case axis
        when :x
          base_image.columns
        when :y
          base_image.rows
        else
          nil
        end
      end

      # Get an array of colour values for the pixel at the given coordinates.
      def get_pixel_colour( x, y )
        p = base_image.pixel_color( x, y )
        [ p.red, p.green, p.blue, p.opacity ]
      end

      # Set the colour of the pixel at the given coordinates.
      def set_pixel_colour( x, y, colour )
        p = base_image.pixel_color( x, y, Magick::Pixel.new( *colour ) )
        [ p.red, p.green, p.blue, p.opacity ]
      end

      # Flip the image on the given axis.
      def invert( axis )
        case axis
        when :x
          self.class.new( base_image.flip )
        when :y
          self.class.new( base_image.flop )
        else
          nil
        end
      end

      # Flip the image on the given axis (destructive).
      def invert!( axis )
        case axis
        when :x
          base_image.flip!
        when :y
          base_image.flop!
        else
          nil
        end
      end

      # Rotate image by the number of degrees given.
      def rotate( deg )
        self.class.new( base_image.rotate( deg ) )
      end

      # The full path of the underlying image file
      def file_path
        base_image ? base_image.base_filename : nil
      end

      # Write image to disk
      def write( path )
        base_image.write( path )
      end

    end
  end
end
