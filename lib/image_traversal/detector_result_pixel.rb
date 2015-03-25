module ImageTraversal

  class Detector
    
    class Result

      class Pixel
        attr_reader :x, :y, :colour_state

        def initialize( x, y, colour_state )
          @x = x
          @y = y
          @colour_state = colour_state
        end

        def coords
          [ @x, @y ]
        end

      end

    end
  end
end
