module ImageTraversal
  class Palette
    
    class << self
      def max_colour_value; ImageTraversal.image_adapter_class.max_colour_value end
      def black; [ 0, 0, 0, 0] end
      def white; [ max_colour_value, max_colour_value, max_colour_value, 0 ] end
      def annotate_density_reached; [ 65535, 0, 0, 0 ] end
      def annotate_pixel_is_colour; [ 0, 0, 65535, 0 ] end
      def annotate_nil; [ 0, 65535, 0, 0 ] end
    end
  end
end
