require File.expand_path( "../../test_helper.rb", __FILE__ )
module Chunking

  class AdapterMagickImageTest < TestCase

    def max_colour_value
      Magick::Image::QuantumRange
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
      rows = rand( 100 )
      cols = rand( 100 )
      base_image = Magick::Image.new( cols, rows )
      adapter = Image::AdapterMagickImage.new( base_image )
      assert_equal cols, adapter.size( :x )
      assert_equal rows, adapter.size( :y )
    end

  end
end
