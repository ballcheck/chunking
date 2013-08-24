# TODO: run these test again, inverting the colour.
# TODO: run these tests again, swapping image library

# TODO: is this being included? should we even use array in this way?
require "array.rb"
module Behavioral
  module Setup
    def setup
      @axis = :x
      @rgb = ::Chunking::Image::RMagickImage::BLACK_RGB
      @foreground_rgb = @rgb
      @background_rgb = ::Chunking::Image::RMagickImage::WHITE_RGB
    end

    def invert?
      false
    end

    def build_image_from_pixel_map( pixel_map )
      Chunking::Image::RMagickImage.new_from_pixel_map pixel_map
    end
  end

  # Tests that are NOT affected if bg/fg colours are inverted.
  module ColourFastTests
    include Setup
    def test_start_index
      o = @background_rgb
      x = @foreground_rgb
      pixel_map = [
        [ o, o, o, o, o ],
        [ x, x, x, x, x ],
        [ o, o, o, o, o ],
        [ o, o, o, o, o ],
        [ x, x, x, x, x ],
        [ o, o, o, o, o ]
      ]

      img = build_image_from_pixel_map pixel_map

      # TODO: remove these 2 lines from all over this file
      img = img.rotate( -90 ) if @axis == :y
      img = img.invert( @axis ) if invert?

      detector = Chunking::Detector.new( :axis => @axis, :size => 5, :rgb => @rgb )

      # immediate boundary
      assert_equal 1, detector.detect_boundary( img, 0, invert? ).index
      # jump a row to boundary
      assert_equal 4, detector.detect_boundary( img, 2, invert? ).index
      # same boundary different start
      assert_equal 4, detector.detect_boundary( img, 3, invert? ).index
      # last row
      assert_equal nil, detector.detect_boundary( img, 5, invert? )
    end

    def test_invert
      o = @background_rgb
      x = @foreground_rgb
      pixel_map = [
        [ o, o, o, o, o ],
        [ x, x, x, x, x ],
        [ o, o, o, o, o ],
        [ o, o, o, o, o ],
      ]

      img = build_image_from_pixel_map pixel_map
      img = img.rotate( -90 ) if @axis == :y
      img = img.invert( @axis ) if invert?

      size = img.size( @axis )

      detector = Chunking::Detector.new( :axis => @axis, :size => size, :rgb => @rgb )
      assert_equal 1, detector.detect_boundary( img, 0, invert? ).index
     
      detector = Chunking::Detector.new( :axis => @axis, :size => size, :rgb => @rgb )
      assert_equal 2, detector.detect_boundary( img, 0, !invert? ).index
    end

    def test_fuzz
      # TODO: test fuzz
    end

    def test_no_matches
      o = @background_rgb
      x = @foreground_rgb
      pixel_map = [
        [ o, o, o, o, o ],
        [ o, o, o, o, o ],
        [ o, o, o, o, o ],
      ]

      img = build_image_from_pixel_map pixel_map
      img = img.rotate( -90 ) if @axis == :y
      img = img.invert( @axis ) if invert?
      size = img.size( @axis )

      detector = Chunking::Detector.new( :axis => @axis, :size => size, :rgb => @rgb )
      assert_equal nil, detector.detect_boundary( img, 0, invert? )
    end

    def test_all_matches
      # TODO: eh? waaa?
      # this is covered by inverting bg/fg colours
    end
  end
  
  # Tests that ARE affected if bg/fg colours are inverted.
  module NonColourFastTests
    include Setup
    def test_offset
      o = @background_rgb
      x = @foreground_rgb
      pixel_map = [
        [ o, o, o, o, o ],
        [ x, o, o, o, o ],
        [ x, x, o, o, o ],
        [ x, x, x, o, o ],
        [ x, x, x, x, o ],
        [ x, x, x, x, x ]
      ]

      img = build_image_from_pixel_map pixel_map
      img = img.rotate( -90 ) if @axis == :y
      img = img.invert( @axis ) if invert?

      size = img.size( @axis )

      size.times do |i|
         detector = Chunking::Detector.new( :axis => @axis, :offset => i, :size => size - i, :rgb => @rgb )
         assert_equal i+1,  detector.detect_boundary( img, 0, invert? ).index
      end
    end

    # TODO: what should happen when detector bigger than image?
    def test_size
      o = @background_rgb
      x = @foreground_rgb
      pixel_map = [
        [ o, o, o, o, o ],
        [ o, o, o, o, x ],
        [ o, o, o, x, x ],
        [ o, o, x, x, x ],
        [ o, x, x, x, x ],
        [ x, x, x, x, x ]
      ]

      img = build_image_from_pixel_map pixel_map
      img = img.rotate( -90 ) if @axis == :y
      img = img.invert( @axis ) if invert?

      size = img.size( @axis )

      size.times do |i|
         detector = Chunking::Detector.new( :axis => @axis, :size => size - i, :rgb => @rgb )
         assert_equal i+1, detector.detect_boundary( img, 0, invert? ).index
      end
    end

    def test_density
      o = @background_rgb
      x = @foreground_rgb
      pixel_map = [
        [ o, o, o, o, o ],
        [ o, o, x, o, o ],
        [ o, x, x, o, o ],
        [ o, x, x, x, o ],
        [ x, x, x, x, o ],
        [ x, x, x, x, x ]
      ]

      img = build_image_from_pixel_map pixel_map
      img = img.rotate( -90 ) if @axis == :y
      img = img.invert( @axis ) if invert?

      size = img.size( @axis )

      5.times do |i|
         detector = Chunking::Detector.new( :axis => @axis, :density => i + 1, :size => size, :rgb => @rgb )
         assert_equal i+1, detector.detect_boundary( img, 0, invert? ).index
      end
    end

    def test_tolerance
      o = @background_rgb
      x = @foreground_rgb
      pixel_map = [
        [ o, o, o, o, o ],
        [ x, o, o, o, o ],
        [ o, o, o, o, x ],
        [ o, x, o, o, o ],
        [ o, o, o, x, o ],
        [ o, o, x, o, o ],
      ]

      img = build_image_from_pixel_map pixel_map
      img = img.rotate( -90 ) if @axis == :y
      img = img.invert( @axis ) if invert?

      size = img.size( @axis )

      5.times do |i|
        detector = Chunking::Detector.new( :axis => @axis, :tolerance => i, :size => size, :rgb => @rgb )
        assert_equal i+1, detector.detect_boundary( img, 0, invert? ).index
      end
    end
  end

  module AllTests
    include ColourFastTests
    include NonColourFastTests
  end
end
