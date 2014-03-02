require File.expand_path( "../../test_helper.rb", __FILE__ )
require File.expand_path( "../../../../../lib/image_traversal/image/pixel_colour.rb", __FILE__ )

module ImageTraversal
  
  module Image
    class MixedIn
      # include module in dummy class for testing.
      include PixelColour
    end
  end

  class PixelColourTest < TestCase

    def max_colour_value
      Palette.max_colour_value
    end

    def test_compare_single_colours_method
      klass = Image::MixedIn
      a, b = (0..max_colour_value).to_a.sample( 2 )

      # in/equality
      assert klass.compare_single_colours?( a, a )
      assert !klass.compare_single_colours?( a, b )

      # tolerance works
      required_tolerance = (a-b).abs
      assert klass.compare_single_colours?( a, b, required_tolerance )
      assert !klass.compare_single_colours?( a, b, required_tolerance-1 )
    end

    def test_compare_colours_method
      klass = Image::MixedIn
      tolerance = stub( "tolerance" )

      r_a, g_a, b_a, a_a = stub( "r_a" ), stub( "g_a" ), stub( "b_a" ), stub( "a_a" )
      colour_a = [ r_a, g_a, b_a, a_a ]
      
      r_b, g_b, b_b, a_b = stub( "r_b" ), stub( "g_b" ), stub( "b_b" ), stub( "a_b" )
      colour_b = [ r_b, g_b, b_b, a_b ]

      # equality
      klass.stubs( :compare_single_colours? ).with( r_a, r_b, tolerance ).returns( true )
      klass.stubs( :compare_single_colours? ).with( g_a, g_b, tolerance ).returns( true )
      klass.stubs( :compare_single_colours? ).with( b_a, b_b, tolerance ).returns( true )
      klass.stubs( :compare_single_colours? ).with( a_a, a_b, tolerance ).returns( true )
      assert klass.compare_colours?( colour_a, colour_b, tolerance )

      # inequality
      klass.stubs( :compare_single_colours? ).with( r_a, r_b, tolerance ).returns( true )
      klass.stubs( :compare_single_colours? ).with( g_a, g_b, tolerance ).returns( true )
      klass.stubs( :compare_single_colours? ).with( b_a, b_b, tolerance ).returns( true )
      klass.stubs( :compare_single_colours? ).with( a_a, a_b, tolerance ).returns( false )
      assert !klass.compare_colours?( colour_a, colour_b, tolerance )
    end

    def test_pixel_is_colour_method
      image = Image::MixedIn.new

      # create dummy values
      fuzz = stub( "fuzz" )
      coords_a = [ stub( "x_a" ), stub( "y_a" ) ]
      coords_b = [ stub( "x_b" ), stub( "y_b" ) ]
      colour_a = stub( "colour_a" )
      colour_b = stub( "colour_b" )
      colour_x = stub( "colour_x" )

      # equality
      image.stubs( :get_pixel_colour ).with( *coords_a ).returns( colour_a )
      image.class.stubs( :compare_colours? ).with( colour_x, colour_a, fuzz ).returns( true )
      assert image.pixel_is_colour?( *coords_a, colour_x, fuzz )

      # inequality
      image.stubs( :get_pixel_colour ).with( *coords_b ).returns( colour_b )
      image.class.stubs( :compare_colours? ).with( colour_x, colour_b, fuzz ).returns( false )
      assert !image.pixel_is_colour?( *coords_b, colour_x, fuzz )

      # with an array of colours
      colours_x = [ [ stub( "colours_x1" ) ], [ stub( "colours_x2" ) ] ]

      # equality
      image.class.stubs( :compare_colours? ).with( colours_x[0], colour_a, fuzz ).returns( false )
      image.class.stubs( :compare_colours? ).with( colours_x[1], colour_a, fuzz ).returns( false )
      assert !image.pixel_is_colour?( *coords_a, colours_x, fuzz )

      # inequality
      image.class.stubs( :compare_colours? ).with( colours_x[0], colour_b, fuzz ).returns( false )
      image.class.stubs( :compare_colours? ).with( colours_x[1], colour_b, fuzz ).returns( true )
      assert image.pixel_is_colour?( *coords_b, colours_x, fuzz )
    end

    def test_compare_colours_method_without_mocks
      klass = Image::MixedIn
      r, g, b, a, x = (0..max_colour_value).to_a.sample( 5 )

      # rgb equality (same principle for cmy)
      #assert klass.compare_colours?( [r, g, b], [r, g, b] )

      # rgba equality (same principle for cmyk)
      assert klass.compare_colours?( [r, g, b, a], [r, g, b, a] )

      # opacity is optional
      #assert klass.compare_colours?( [r, g, b], [r, g, b, a] )
      #assert klass.compare_colours?( [r, g, b, a], [r, g, b] )

      # tolerance works
      colour = [r, g, b, a]
      inequal_colour = colour.reverse
      required_tolerance = colour.zip( inequal_colour ).map{ |a,b| (a-b).abs }.max
      assert klass.compare_colours?( colour, inequal_colour, required_tolerance )
      assert !klass.compare_colours?( colour, inequal_colour, required_tolerance-1 )

      # inequality at any index / combination of indexes
      # e.g. [[0], [1], [2], [3], [0, 1], [0, 2], [0, 3], [1, 2], [1, 3], [2, 3], [0, 1, 2], [0, 1, 3], [0, 2, 3], [1, 2, 3]]
      possible_index_combinations = (1..3).map{ |i| [0, 1, 2, 3].combination( i ).to_a }.flatten( 1 )
      possible_index_combinations.each do |i|
        colour = [ r, g, b, a ]
        inequal_colour = (0..3).to_a.map{ |p| i.include?( p ) ? x : colour[p] }

        # inequality
        assert !klass.compare_colours?( colour, inequal_colour )

        # tolerance works
        required_tolerance = colour.zip( inequal_colour ).map{ |a,b| (a-b).abs }.max
        assert klass.compare_colours?( colour, inequal_colour, required_tolerance )
        assert !klass.compare_colours?( colour, inequal_colour, required_tolerance-1 )
      end
        
    end

  end
end
