require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectorResultTest < TestCase

    def test_should_set_colour_state_and_detect_colour
      result = build_result

      assert !result.colour_detected?

      # then...
      result.set_colour_state( true )
      assert result.colour_detected?

      # also...
      result.set_colour_state( false )
      assert !result.colour_detected?
    end

    def test_should_add_pixel
      # create result with no pixels.
      result = build_result
      assert_equal [], result.pixels
      
      # stub out creating a pixel
      x = stub( "x" )
      y = stub( "y" )
      colour_state = stub( "colour_state" )
      pixel = stub( "pixel" )
      Detector::Result::Pixel.stubs( :new ).with( x, y, colour_state ).returns( pixel )

      # then...
      result.add_pixel( x, y, colour_state )
      assert_equal [ pixel ], result.pixels
    end

    def test_should_annotate_image
      result = build_result

      # add pixels to result using stubbed values.
      x1, y1, colour_state1 = stub( "x1" ), stub( "y1" ), false
      x2, y2, colour_state2 = stub( "x2" ), stub( "y2" ), true
      result.add_pixel( x1, y1, colour_state1 )
      result.add_pixel( x2, y2, colour_state2 )

      # then...
      # expect image to be annotated with different colours depending on state.
      image = mock( "image" )
      image.expects( :set_pixel_colour ).once.with( x1, y1, Palette.annotate_nil )
      image.expects( :set_pixel_colour ).once.with( x2, y2, Palette.annotate_pixel_is_colour )
      result.annotate!( image )

      # also...
      # when result.colour_detected? use colour annotate_density_reached for the last pixel.
      result.set_colour_state( true )
      assert result.colour_detected?
   
      image = mock( "image" )
      image.expects( :set_pixel_colour ).once.with( x1, y1, Palette.annotate_nil )
      image.expects( :set_pixel_colour ).once.with( x2, y2, Palette.annotate_density_reached )
      result.annotate!( image )
    end
  end

end
