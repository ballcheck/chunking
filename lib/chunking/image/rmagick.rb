# TODO: untested
require File.expand_path( "../base.rb", __FILE__ )
require "RMagick"

module Chunking
  module Image
    # An extension of Image::Base wrapper for RMagick
    class RMagickImage < Base
      BLACK_RGB = [ 0, 0, 0 ]
      WHITE_RGB = [ Magick::QuantumRange, Magick::QuantumRange, Magick::QuantumRange ]

      attr_reader :base_image

      # Either a) create a wrapper for a pre-existing base_image or b) create a new blank base_image from rows and cols.
      def initialize( *args )
        if args[0].is_a?( Magick::Image )
          @base_image = args[0]
        else
          @base_image = Magick::Image.new( *args )
        end
      end

      # Check equality of 2 rgb values.
      def self.compare_colours?( rgb1, rgb2, fuzz )
        Magick::Pixel.new( *rgb1 ).fcmp(  Magick::Pixel.new( *rgb2 ), fuzz )
      end

      # Determine the size of the base_image on the given axis.
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

      # Get the colour of the pixel at the given coordinates.
      def get_pixel_colour( x, y )
        #-- TODO: must be a method to do this
        p = base_image.pixel_color( x, y )
        [ p.red, p.green, p.blue, p.opacity ]
      end

      # Set the colour of the pixel at the given coordinates.
      def set_pixel_colour( x, y, rgba )
        p = base_image.pixel_color( x, y, Magick::Pixel.new( *rgba ) )
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

      # Rotate image by the number of degrees given.
      def rotate( deg )
        self.class.new( base_image.rotate( deg ) )
      end
    end
  end
end
