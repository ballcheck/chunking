require File.expand_path( "../../../lib/chunking/image/base.rb", __FILE__ )

# TODO: all these nils seem suspicious.
class PixelIsColourTest < ActiveSupport::TestCase
  def test_equality
    img = Chunking::Image::Base.new( nil )
    img.stubs( :get_pixel_colour )
    img.class.expects( :compare_colours ).returns( true )
    assert img.pixel_is_colour?( nil, nil, [nil], nil )
  end

  def test_inequality
    img = Chunking::Image::Base.new( nil )
    img.stubs( :get_pixel_colour )
    img.class.expects( :compare_colours ).returns( false )
    assert !img.pixel_is_colour?( nil, nil, [nil], nil )
  end

  def test_array_of_colours
    img = Chunking::Image::Base.new( nil )
    img.stubs( :get_pixel_colour )
    colours = [ [nil], [nil], [nil] ]
    img.class.expects( :compare_colours ).times( colours.length ).returns( false )
    img.pixel_is_colour?( nil, nil, colours, nil )
  end

  def test_equal_if_any_item_is_equal
    img = Chunking::Image::Base.new( nil )
    img.stubs( :get_pixel_colour )
    colours = [ [nil], [nil], [nil] ]
    img.class.expects( :compare_colours ).times( 1 ).returns( true )
    img.pixel_is_colour?( nil, nil, colours, nil )
  end
    
end
