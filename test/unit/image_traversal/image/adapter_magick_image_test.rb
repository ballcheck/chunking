require File.expand_path( "../../test_helper.rb", __FILE__ )
require "RMagick"
module ImageTraversal

  class AdapterMagickImageTest < TestCase

    def max_colour_value
      ::Magick::QuantumRange
    end

    def test_initialize
      base_image = stub( "base_image" )
      adapter = Image::AdapterMagickImage.new( base_image )
      assert_equal base_image, adapter.base_image
    end

    # TODO: not sure how to test this adapter without - 
    # a) testing functionality already testing by RMagick
    # b) writing heavily mocked test that are brittle.

    def test_method_size
      width, height  = (1..100).to_a.sample( 2 )
      base_image = Magick::Image.new( width, height )
      image_adapter = Image::AdapterMagickImage.new( base_image )
      
      # maps width/height to size( :x ) / size ( :y )
      assert_equal width, image_adapter.size( :x )
      assert_equal height, image_adapter.size( :y )
    end

    def test_set_and_get_pixel_colour_methods
      width, height  = (1..100).to_a.sample( 2 )

      coords = [ (0..width).to_a.sample, (0..height).to_a.sample ]
      initial_colour = [ max_colour_value, max_colour_value, max_colour_value, 0 ]
      new_colour = (0..max_colour_value).to_a.sample( 4 )
      
      base_image = Magick::Image.new( width, height )
      base_image.alpha(Magick::ActivateAlphaChannel)
      image_adapter = Image::AdapterMagickImage.new( base_image )

      # gets/set colour at coords
      assert_equal initial_colour, image_adapter.get_pixel_colour( *coords )
      image_adapter.set_pixel_colour( *coords, new_colour )
      assert_equal new_colour, image_adapter.get_pixel_colour( *coords )
    end

      
  end
end
