# TODO: run these test again, inverting the colour.
# TODO: run these tests again, swapping image library
module BehavioralTest
  module Setup
    def setup
      @axis = :x
      @rgb = [ 0, 0, 0 ]
      @foreground_rgb = @rgb
      @background_rgb = [ 65535, 65535, 65535 ]
    end

    def invert?
      false
    end

    def build_image_from_pixel_map( pixel_map )
      Chunking::Image::RMagickImage.new_from_pixel_map pixel_map
    end
  end

  module ColourFast
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
      # this is covered by inverting bg/fg colours
    end
  end
  
  module NonColourFast
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

  module All
    include BehavioralTest::ColourFast
    include BehavioralTest::NonColourFast
  end
end

class BehavioralTestXAxis < ActiveSupport::TestCase
  include BehavioralTest::All
end

class BehavioralTestYAxis < ActiveSupport::TestCase
  include BehavioralTest::All

  def setup
    super
    @axis = :y
  end
end

class BehavioralTestXAxisInvert < ActiveSupport::TestCase
  include BehavioralTest::All

  def invert?
    true
  end
end

class BehavioralTestYAxisInvert < ActiveSupport::TestCase
  include BehavioralTest::All

  def setup
    super
    @axis = :y
  end

  def invert?
    true
  end
end

# NOTE: starting on colour, moving off. 
# TODO: this does not work on some tests
class BehavioralTestXAxisSwapFGBG < ActiveSupport::TestCase
  include BehavioralTest::ColourFast

  def setup
    super
    @background_rgb = @rgb
    @foreground_rgb = nil
  end
end
