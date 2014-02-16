require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectorResultTest < TestCase

    def test_should_set_colour_state_and_detect_colour
      result = Detector::Result.new

      assert !result.colour_detected?

      result.set_colour_state( true )
      assert result.colour_detected?

      result.set_colour_state( false )
      assert !result.colour_detected?
    end

    def test_should_add_pixel
      result = Detector::Result.new

      assert_equal [], result.pixels

      x = stub( "x" )
      y = stub( "y" )
      colour_state = stub( "colour_state" )

      pixel = stub( "pixel" )
      Detector::Result::Pixel.expects( :new ).with( x, y, colour_state ).returns( pixel )

      result.add_pixel( x, y, colour_state )
      assert_equal [ pixel ], result.pixels
    end

    # Detector::Result::Pixel tests
    def test_should_initialize
      x = stub( "x" )
      y = stub( "y" )
      colour_state = stub( "colour_state" )
      pixel = Detector::Result::Pixel.new( x, y, colour_state )

      assert_equal x, pixel.x
      assert_equal y, pixel.y
      assert_equal colour_state, pixel.colour_state

      assert_equal [ x, y ], pixel.coords
    end

  end

end
