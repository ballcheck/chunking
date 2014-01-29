require File.expand_path( "../pixel_color.rb", __FILE__ )
require "RMagick"

module Chunking
  module Image
    # TODO: coupled to rmagick.
    BLACK_RGB = [ 0, 0, 0 ]
    WHITE_RGB = [ Magick::QuantumRange, Magick::QuantumRange, Magick::QuantumRange ]

    # TODO: test this bad-boy
    # Adapter class providing loose-coupling with RMagick
    class AdapterMagickImage
      include PixelColor
      attr_reader :base_image

      # TODO: don't think the factory should be in the adapter.
      def self.factory( *args, &block )
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

      def initialize( base_image )
        @base_image = base_image
      end

      # TODO: forward calls to the base_image as this is an adapter

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

      # TODO: rename
      # Maximum value for any single colour value ( r/g/b/a/c/m/k/y )
      def quantum_range
        Magick::QuantumRange
      end

      # TODO: this is extended functionality, remove from adapter.
      # Create a blank image of the same size, but with a transparent background.
      def create_mask( *args )
        self.class.factory( size( :x ), size( :y ) ){ self.background_color = "none" }
      end

      # The full path of the underlying image file
      def file_path
        base_image ? base_image.base_filename : nil
      end

      # TODO: this is extended functionality, remove from adapter.
      # Annotate this image using another as a mask
      def annotate( mask, opacity )
        new_image = base_image.dissolve( mask.base_image, opacity, 1 )
        self.class.new( new_image )
      end

      # Write image to disk
      def write( path )
        base_image.write( path )
      end

    end
  end
end
