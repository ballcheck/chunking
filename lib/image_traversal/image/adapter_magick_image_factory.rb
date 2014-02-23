require "RMagick"

module ImageTraversal
  module Image
    # Factory method for AdapterMagickImage.
    module AdapterMagickImageFactory
      module ClassMethods
        def factory( *args, &block )
          arg = args[0]

          if arg.is_a?( Magick::Image )
            self.new( arg )
          elsif arg.is_a?( String )
            # assume it's a file path
            self.new( Magick::Image.read( arg ).first )
          elsif arg.is_a?( Array )
            # assume it's a pixel map
            build_image_from_pixel_map( arg )
          else
            # give the lib a chance
            self.new( Magick::Image.new( *args, &block ) )
          end
        end

        # Build a new image based an array of pixels
        def from_pixel_map( pixel_map )
          # blank image same size as pixel_map
          magick_image = Magick::Image.new( pixel_map.first.length, pixel_map.length )

          # draw pixel_map
          return self.new( magick_image ).draw_pixel_map!( pixel_map )
        end
      end
    end
  end
end

