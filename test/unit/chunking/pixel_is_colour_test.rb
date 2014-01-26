require File.expand_path( "../test_helper.rb", __FILE__ )
require File.expand_path( "../../../../lib/chunking/image/base.rb", __FILE__ )
module Chunking
  class PixelIsColourTest < TestCase
    def test_equality
      img = Image::Base.new
      img.stubs( :get_pixel_colour )
      img.class.expects( :compare_colours? ).returns( true )
      assert img.pixel_is_colour?( nil, nil, [nil], nil )
    end

    def test_inequality
      img = Image::Base.new
      img.stubs( :get_pixel_colour )
      img.class.expects( :compare_colours? ).returns( false )
      assert !img.pixel_is_colour?( nil, nil, [nil], nil )
    end

    def test_array_of_colours
      img = Image::Base.new
      img.stubs( :get_pixel_colour )
      colours = [ [nil], [nil], [nil] ]
      img.class.expects( :compare_colours? ).times( colours.length ).returns( false )
      img.pixel_is_colour?( nil, nil, colours, nil )
    end

    def test_equal_if_any_item_is_equal
      img = Image::Base.new
      img.stubs( :get_pixel_colour )
      colours = [ [nil], [nil], [nil] ]
      # runs 3 times, but if you switch them it runs once.
      img.class.expects( :compare_colours? ).times( 1 ).returns( true )
      img.class.expects( :compare_colours? ).times( 2 )
      img.pixel_is_colour?( nil, nil, colours, nil )
    end

  end
end
