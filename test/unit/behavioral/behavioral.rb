# TODO: run these test again, inverting the colour.
# TODO: run these tests again, swapping image library

# TODO: is this being included? should we even use array in this way?
require "array.rb"
# A suite of behavioural tests written in such a way that the tests can be repeated under varying conditions.
module Behavioral
  # These methods get overridden in test_cases.rb in this module.
  module Setup
    # Set up for the test.
    def setup
      @axis = :x
      @rgb = ::Chunking::Image::RMagickImage::BLACK_RGB
      @foreground_rgb = @rgb
      @background_rgb = ::Chunking::Image::RMagickImage::WHITE_RGB
    end

    # Whether the image should be inverted for this test or not.
    def invert?
      false
    end

    # Provides loose-coupling with the method of the same name in the image library.
    def build_image_from_pixel_map( pixel_map )
      Chunking::Image::RMagickImage.new_from_pixel_map pixel_map
    end
  end

  # Tests that work the same when background / foreground colours are inverted.
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
      # TODO: method not implemented
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

    # def test_all_matches
    # # this is covered by inverting bg/fg colours
    # end
  end
  
  # Tests that break if background / foreground colours are inverted.
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

    def test_size
      # TODO: what should happen when detector bigger than image?
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
        [ o, o, o ],
        [ x, o, o ],
        [ o, o, o ],
        [ o, x, o ],
        [ o, x, o ],
        [ o, o, o ],
        [ o, o, x ],
        [ o, o, x ],
        [ o, o, x ],
      ]

      img = build_image_from_pixel_map pixel_map
      img = img.rotate( -90 ) if @axis == :y
      img = img.invert( @axis ) if invert?

      size = img.size( @axis )

      tolerance_index_map = {
        0 => 1,
        1 => 3,
        2 => 6#,
        # TODO: at present, nil breaks test
        #3 => nil
      }

      (0..2).each do |i|
        detector = Chunking::Detector.new( :axis => @axis, :tolerance => i, :size => size, :rgb => @rgb )
        assert_equal tolerance_index_map[i], detector.detect_boundary( img, 0, invert? ).index
      end
    end
  end

  # Container for ColourFastTests and NonColourFastTests
  module AllTests
    include ColourFastTests
    include NonColourFastTests
  end
end
