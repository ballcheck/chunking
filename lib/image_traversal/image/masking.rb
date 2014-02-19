module ImageTraversal
  module Image
    module Masking

      # Create a blank image of the same size, but with a transparent background.
      def create_mask
        self.class.factory( size( :x ), size( :y ) ){ self.background_color = "none" }
      end

      # Annotate this image using another as a mask
      def apply_mask( mask, opacity = 1 )
        dissolve( mask.base_image, opacity, 1 )
      end

    end
  end
end
