require File.expand_path( "../../test_helper.rb", __FILE__ )
module Chunking

  class AdapterMagickImageTest < TestCase

    def test_initialize
      image = stub( "magick_image" )
      adapter = Image::AdapterMagickImage.new( image )
      assert_equal image, adapter.base_image
    end

    # TODO: check online if this is too closely testing the implementation
    def test_method_size
      rows = stub( "rows" )
      cols = stub( "columns" )
      image = mock( "magick_image", :rows => rows, :columns => cols )
      adapter = Image::AdapterMagickImage.new( image )
      assert_equal cols, adapter.size( :x )
      assert_equal rows, adapter.size( :y )
    end

    # -----------------
    # Behavioural tests
    # -----------------

    def test_method_size_behaviour
      rows = 1
      cols = 2
      magick_image = Magick::Image.new( cols, rows )
      adapter = Image::AdapterMagickImage.new( magick_image )
      assert_equal cols, adapter.size( :x )
      assert_equal rows, adapter.size( :y )
    end
  end
end
