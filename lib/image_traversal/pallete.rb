module ImageTraversal
  module Pallete
    class << self
      def black; [0,0,0] end
      def annotate_density_reached; [ 65535, 0, 0, 0 ] end
      def annotate_pixel_is_colour; [ 0, 0, 65535 ] end
      def annotate_nil; [ 40000, 40000, 40000 ] end
    end
  end
end
