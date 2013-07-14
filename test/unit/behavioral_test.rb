# TODO: run these test again, inverting the colour.
# TODO: run these tests again, swapping image library
module BehavioralTest
  def setup
    @axis = :x
    @rgb = [10000, 10000, 10000]
    @background_rgb = nil
    @foreground_rgb = @rgb
  end

  def invert?
    false
  end

  def build_image_from_pixel_map( pixel_map )
    Chunking::Image::RMagickImage.new_from_pixel_map pixel_map
  end

  def test_start_index
    # given
    o = @background_rgb
    x = @foreground_rgb
    pixel_map = [
      [ o, o, o, o, o ],
      [ x, x, x, x, x ],
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

    # on first row
    assert_equal 1, detector.detect_boundary( img, 0, invert? ).index
    # where initial row is boundary
    assert_equal 3, detector.detect_boundary( img, 2, invert? ).index
    # jump a row to boundary
    assert_equal 6, detector.detect_boundary( img, 4, invert? ).index
    # same boundary different start
    assert_equal 6, detector.detect_boundary( img, 5, invert? ).index
    # last row
    assert_equal nil, detector.detect_boundary( img, 7, invert? )
  end


  def test_offset
    o = @background_rgb
    x = @foreground_rgb
    pixel_map = [
      [ o, o, o, o, o ],
      [ x, o, o, o, o ],
      [ o, x, o, o, o ],
      [ o, o, x, o, o ],
      [ o, o, o, x, o ],
      [ o, o, o, o, x ]
    ]

    img = build_image_from_pixel_map pixel_map
    img = img.rotate( -90 ) if @axis == :y
  # TODO: needed this because the map doesn't work as offset is from top, not bottom.
    #img = img.invert( :x ) if @axis == :y
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
      [ o, o, o, x, o ],
      [ o, o, x, o, o ],
      [ o, x, o, o, o ],
      [ x, o, o, o, o ]
    ]

    img = build_image_from_pixel_map pixel_map
    img = img.rotate( -90 ) if @axis == :y
  # TODO: needed this because the map doesn't work as offset is from top, not bottom.
    #img = img.invert( :x ) if @axis == :y
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

    size.times do |i|
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

    size.times do |i|
       detector = Chunking::Detector.new( :axis => @axis, :tolerance => i, :size => size, :rgb => @rgb )
       assert_equal i+1, detector.detect_boundary( img, 0, invert? ).index
    end
  end

  def test_invert
  end

  def test_fuzz
  end

  def test_no_matches
  end

  def test_all_matches
  end
end

class BehavioralTestXAxis < ActiveSupport::TestCase
  include BehavioralTest
end

class BehavioralTestYAxis < ActiveSupport::TestCase
  include BehavioralTest

  def setup
    super
    @axis = :y
  end
end

class BehavioralTestXAxisInvert < ActiveSupport::TestCase
  include BehavioralTest

  def invert?
    true
  end
end

class BehavioralTestYAxisInvert < ActiveSupport::TestCase
  include BehavioralTest

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
=begin
class BehavioralTestXAxisSwapFGBG < ActiveSupport::TestCase
  include BehavioralTest

  def setup
    super
    #@rgb = [10000, 10000, 10000]
    #@background_rgb = @rgb
    #@foreground_rgb = nil
  end
end
=end
