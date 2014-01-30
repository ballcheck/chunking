module Chunking
  module Image
    module Masking

      # TODO: review how masking works
      # Create a blank image of the same size, but with a transparent background.
      def create_mask( *args )
        self.class.factory( size( :x ), size( :y ) ){ self.background_color = "none" }
      end

      # Annotate this image using another as a mask
      def annotate( mask, opacity )
        new_image = base_image.dissolve( mask.base_image, opacity, 1 )
        self.class.new( new_image )
      end

    end
  end
end
