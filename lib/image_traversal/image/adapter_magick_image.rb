require File.expand_path( "../pixel_colour.rb", __FILE__ )
require File.expand_path( "../masking.rb", __FILE__ )
require File.expand_path( "../adapter_magick_image_factory.rb", __FILE__ )
require "RMagick"

module ImageTraversal
  module Image
    # Adapter class providing loose-coupling with RMagick
    class AdapterMagickImage
      include PixelColour
      include Masking
      extend AdapterMagickImageFactory::ClassMethods
      attr_reader :base_image

      class << self
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
          set_base_image( base_image.flip )
        when :y
          set_base_image( base_image.flop )
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

      def to_pixel_map
        pixels = self.base_image.export_pixels
        pixels_rgb = pixels.each_slice( 3 ).to_a
        pixel_map = pixels_rgb.each_slice( self.base_image.rows ).to_a
      end

      # Rotate image by the number of degrees given.
      def rotate( deg )
        set_base_image( base_image.rotate( deg ) )
      end

      # The full path of the underlying image file
      def file_path
        base_image ? base_image.base_filename : nil
      end

      # Write image to disk
      def write( path )
        base_image.write( path )
      end

      def dissolve( *args )
        new_image = base_image.dissolve( *args )
        set_base_image( new_image )
      end

      private

      def set_base_image( img )
        @base_image = img
        self
      end
    end
  end
end
