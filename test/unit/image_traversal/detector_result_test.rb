require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectorResultTest < TestCase

    def test_should_set_colour_state_and_detect_colour
      result = build_result

      assert !result.colour_detected?

      result.set_colour_state( true )
      assert result.colour_detected?

      result.set_colour_state( false )
      assert !result.colour_detected?
    end

    def test_should_add_pixel
      result = build_result

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

    def test_should_annotate_image
      image = mock( "image" )

      result = build_result
      assert !result.colour_detected?

      x1, y1, colour_state1 = stub( "x1" ), stub( "y1" ), false
      result.add_pixel( x1, y1, colour_state1 )
      image.expects( :set_pixel_colour ).twice.with( x1, y1, Palette.annotate_nil )

      x2, y2, colour_state2 = stub( "x2" ), stub( "y2" ), true
      result.add_pixel( x2, y2, colour_state2 )
      image.expects( :set_pixel_colour ).once.with( x2, y2, Palette.annotate_pixel_is_colour )

      result.annotate!( image )

      # only annotate density_reached for the last pixel when result.colour_detected?
      result.set_colour_state( true )
      assert result.colour_detected?
   
      image.expects( :set_pixel_colour ).once.with( x2, y2, Palette.annotate_density_reached )

      # do it
      result.annotate!( image )
    end
  end

end
