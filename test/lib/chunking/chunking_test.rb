require "test_helper"
require "#{Rails.root}/lib/vendor/chunking/chunking.rb"
require "RMagick"

class ChunkingTest < ActiveSupport::TestCase
  
  def setup
    @img = Magick::Image.new( 10, 10 )
  end

  test "pixel_is_colour" do
    # Given
    x1 = y1 = 1
    rgb1 = [ 0, 0, 0 ]

    x2 = y2 = 2
    rgb2 = [ 1000, 1000, 1000 ]

    x3 = y3 = 3
    rgb3 = [ 1001, 1001, 1001 ] # similar to rgb2

    # When
    # draw colour pixels on the image
    @img.pixel_color( x1, y1, Magick::Pixel.new( *rgb1 ) )
    @img.pixel_color( x2, y2, Magick::Pixel.new( *rgb2 ) )
    @img.pixel_color( x3, y3, Magick::Pixel.new( *rgb3 ) )

    # Then
    # similarity
    assert Chunking.pixel_is_colour?( @img, x1, y1, rgb1, 0 )
    assert Chunking.pixel_is_colour?( @img, x2, y2, rgb2, 0 )
    assert Chunking.pixel_is_colour?( @img, x3, y3, rgb3, 0 )

    # dissimilarity
    assert !Chunking.pixel_is_colour?( @img, x1, y1, rgb2, 0 )
    assert !Chunking.pixel_is_colour?( @img, x1, y1, rgb3, 0 )
    assert !Chunking.pixel_is_colour?( @img, x2, y2, rgb1, 0 )
    assert !Chunking.pixel_is_colour?( @img, x2, y2, rgb3, 0 )
    assert !Chunking.pixel_is_colour?( @img, x3, y3, rgb1, 0 )
    assert !Chunking.pixel_is_colour?( @img, x3, y3, rgb2, 0 )

    # fuzz
    assert !Chunking.pixel_is_colour?( @img, x2, y2, rgb3, 0 )
    assert Chunking.pixel_is_colour?( @img, x2, y2, rgb3, 1 )
    assert !Chunking.pixel_is_colour?( @img, x2, y2, rgb1, 1 )
  end

end
