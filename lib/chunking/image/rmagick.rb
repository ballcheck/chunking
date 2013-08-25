require File.expand_path( "../base.rb", __FILE__ )
require "RMagick"

# TODO: untested
module Chunking
  module Image
    class RMagickImage < Base
      BLACK_RGB = [ 0, 0, 0 ]
      WHITE_RGB = [ Magick::QuantumRange, Magick::QuantumRange, Magick::QuantumRange ]

      attr_reader :base_image

      def initialize( *args )
        if args[0].is_a?( Magick::Image )
          @base_image = args[0]
        else
          @base_image = Magick::Image.new( *args )
        end
      end

      def self.compare_colours( rgb1, rgb2, fuzz )
        Magick::Pixel.new( *rgb1 ).fcmp(  Magick::Pixel.new( *rgb2 ), fuzz )
      end

      def size( axis )
        case axis
        when :x
          base_image.columns
        when :y
          base_image.rows
        end
      end

      # TODO: not sure about affecting the base_image
      def invert( axis )
        case axis
        when :x
          self.class.new( base_image.flip )
        when :y
          self.class.new( base_image.flop )
        end
      end

      def rotate( deg )
        self.class.new( base_image.rotate( deg ) )
      end

      def get_pixel_colour( x, y )
        # TODO: must be a method to do this
        p = base_image.pixel_color( x, y )
        [ p.red, p.green, p.blue, p.opacity ]
      end

      def set_pixel_colour( x, y, rgba )
        p = base_image.pixel_color( x, y, Magick::Pixel.new( *rgba ) )
        [ p.red, p.green, p.blue, p.opacity ]
      end
    end
  end
end
