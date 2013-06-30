require "RMagick"

# TODO: untested
module Image
  class RMagickImage < Base

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

    def invert( axis )
      case axis
      when :x
        base_image.flip
      when :y
        base_image.flop
      end
    end

    def get_pixel_colour( x, y )
      # TODO: must be a method to do this
      p = base_image.pixel_color( x, y )
      [ p.red, p.green, p.blue, p.opacity ]
    end

    def set_pixel_colour( x, y, rgba )
      p = base_image.pixel_color( x, y, rgba )
      [ p.red, p.green, p.blue, p.opacity ]
    end
  end
end
