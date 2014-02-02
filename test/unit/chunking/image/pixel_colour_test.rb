require File.expand_path( "../../test_helper.rb", __FILE__ )
require File.expand_path( "../../../../../lib/chunking/image/pixel_colour.rb", __FILE__ )

module Chunking
  
  module Image
    class MixedIn
      # include module in dummy class for testing.
      include PixelColour
    end
  end

  class PixelColourTest < TestCase

    def max_colour_value
      Image::AdapterMagickImage.max_colour_value
    end

    def test_method_compare_single_colours
      image = Class.extend( Image::PixelColour::ClassMethods )
      a, b = (0..max_colour_value).to_a.sample( 2 )

      assert image.compare_single_colours?( a, a )
      assert !image.compare_single_colours?( a, b )
      assert image.compare_single_colours?( a, b, (a-b).abs )
      assert !image.compare_single_colours?( a, b, (a-b).abs-1 )
    end

    def test_method_compare_colours
      klass = Class.extend( Image::PixelColour::ClassMethods )
      r, g, b, a = stub( "r" ), stub( "g" ), stub( "b" ), stub( "a" )
      c1 = c2 = [ r, g, b, a ]

      klass.stubs( :compare_single_colours? ).returns( true )
      assert klass.compare_colours?( c1, c2 )

      (0..3).each do |i|
        klass.stubs( :compare_single_colours? ).returns( *Array.new( i, true ) << false )
        assert !klass.compare_colours?( c1, c2 )
      end
    end

    def test_method_pixel_is_colour
      image = Image::MixedIn.new

      # create dummy values
      fuzz = stub( "fuzz" )
      coords_a = [ stub( "x_a" ), stub( "y_a" ) ]
      coords_b = [ stub( "x_b" ), stub( "y_b" ) ]
      colour_a = stub( "colour_a" )
      colour_b = stub( "colour_b" )
      colour_x = stub( "colour_x" )

      # assert equality
      image.stubs( :get_pixel_colour ).with( *coords_a ).returns( colour_a )
      image.class.stubs( :compare_colours? ).with( colour_x, colour_a, fuzz ).returns( true )
      assert image.pixel_is_colour?( *coords_a, colour_x, fuzz )

      # assert inequality
      image.stubs( :get_pixel_colour ).with( *coords_b ).returns( colour_b )
      image.class.stubs( :compare_colours? ).with( colour_x, colour_b, fuzz ).returns( false )
      assert !image.pixel_is_colour?( *coords_b, colour_x, fuzz )

      # it also works for an array of colours.
      colours_x = [ [ stub( "colours_x1" ) ], [ stub( "colours_x2" ) ] ]

      # assert equality
      image.class.stubs( :compare_colours? ).with( colours_x[0], colour_a, fuzz ).returns( false )
      image.class.stubs( :compare_colours? ).with( colours_x[1], colour_a, fuzz ).returns( false )
      assert !image.pixel_is_colour?( *coords_a, colours_x, fuzz )

      # assert inequality
      image.class.stubs( :compare_colours? ).with( colours_x[0], colour_b, fuzz ).returns( false )
      image.class.stubs( :compare_colours? ).with( colours_x[1], colour_b, fuzz ).returns( true )
      assert image.pixel_is_colour?( *coords_b, colours_x, fuzz )
    end

    def test_compare_colours_behaviour
      # This may seem like overkill, but this method is fundamental.
      image = Class.extend( Image::PixelColour::ClassMethods )
      r, g, b, a, x = (0..max_colour_value).to_a.sample( 5 )

      # rgb equality (same principle for cmy)
      assert image.compare_colours?( [r, g, b], [r, g, b] )

      # rgba equality (same principle for cmyk)
      assert image.compare_colours?( [r, g, b, a], [r, g, b, a] )

      # opacity is optional
      assert image.compare_colours?( [r, g, b], [r, g, b, a] )
      assert image.compare_colours?( [r, g, b, a], [r, g, b] )

      # inequality at any combination of indexes
      # e.g. [[0], [1], [2], [3], [0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3], [0, 1, 2], [0, 1, 3], [0, 2, 3], [1, 2, 3]]
      possible_index_combinations = (1..3).map{ |i| [0, 1, 2, 3].combination( i ).to_a }.flatten( 1 )
      possible_index_combinations.each do |i|
        colour = (0..max_colour_value).to_a.sample( 4 )
        inequal_colour = (0..3).to_a.map{ |p| i.include?( p ) ? x : colour[p] }

        assert image.compare_colours?( colour, colour.clone )
        assert !image.compare_colours?( colour, inequal_colour )

        # fuzz (in other words "tolerance")
        required_fuzz = colour.zip( inequal_colour ).map{ |a,b| (a-b).abs }.max
        assert image.compare_colours?( colour, inequal_colour, required_fuzz )
        assert !image.compare_colours?( colour, inequal_colour, required_fuzz-1 )

      end
        
    end

  end
end
