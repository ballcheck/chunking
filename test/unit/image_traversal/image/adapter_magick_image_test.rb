require File.expand_path( "../../test_helper.rb", __FILE__ )
require "RMagick"
module ImageTraversal

  class AdapterMagickImageTest < TestCase

    def max_colour_value
      Palette.max_colour_value
    end

    def test_initialize
      base_image = stub( "base_image" )
      adapter = Image::AdapterMagickImage.new( base_image )
      assert_equal base_image, adapter.base_image
    end

    def test_to_pixel_map
      # random 10x10 img
      width = height = 10
      img = Image::AdapterMagickImage.factory( width, height )

      # populated with random colours
      pixels = (0..max_colour_value).to_a.sample( width*height*3 )
      img.base_image.import_pixels( 0, 0, width, height, "RGB", pixels )
      assert_equal pixels, img.base_image.export_pixels

      # then...
      pixel_map = img.to_pixel_map
      assert_equal pixels, pixel_map.flatten
    end

    # TODO: not sure how to test this adapter without - 
    # a) testing functionality already testing by RMagick
    # b) writing heavily mocked test that are brittle.

    # TODO: test factory method.

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

    def test_should_set_base_image
      old_base_image = stub( "old_base_image" )
      new_base_image = stub( "new_base_image" )
      img = Image::AdapterMagickImage.new( old_base_image )

      # get the original object back.
      assert_equal img, img.send( :set_base_image, new_base_image )

      # base_image has been set.
      assert_equal new_base_image, img.base_image
    end
      
  end
end
