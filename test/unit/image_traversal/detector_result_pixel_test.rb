require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal

  class DetectorResultTest < TestCase
    # Detector::Result::Pixel tests
    def test_should_initialize
      # Given
      x = stub( "x" )
      y = stub( "y" )
      colour_state = stub( "colour_state" )

      # When
      pixel = Detector::Result::Pixel.new( x, y, colour_state )

      # Then
      assert_equal x, pixel.x
      assert_equal y, pixel.y
      assert_equal colour_state, pixel.colour_state
    end

    def test_coords
      # Given
      x = stub( "x" )
      y = stub( "y" )
      colour_state = stub( "colour_state" )
      pixel = Detector::Result::Pixel.new( x, y, colour_state )

      # When
      coords = pixel.coords

      # Then
      assert_equal [ x, y ], coords
    end
  end
end
