class DetectColourTest < ActiveSupport::TestCase
  
  def test_should_detect_colour_if_pixel_is_colour
    detector = build_detector
    img = mock( "img" )
    img.expects( :pixel_is_colour? ).once.returns( true )
    assert detector.detect_colour?( img )
  end

  def test_should_not_detect_colour_if_pixel_is_not_colour
    detector = build_detector
    img = mock( "img" )
    img.expects( :pixel_is_colour? ).returns( false )
    assert !detector.detect_colour?( img, detector )
  end

  def test_should_check_all_pixels
    size = 5
    detector = build_detector( :size => size )
    img = mock( "img" )
    img.expects( :pixel_is_colour? ).times( size ).returns( false )
    assert !detector.detect_colour?( img, detector )
  end

  def test_should_stop_checking_when_detected
    size = 5
    detector = build_detector( :size => size )
    img = mock( "img" )
    img.expects( :pixel_is_colour? ).times( 1 ).returns( true )
    assert detector.detect_colour?( img, detector )
  end

  def test_should_not_return_nil_if_colour_not_detected
    detector = build_detector
    img = mock( "img" )
    img.expects( :pixel_is_colour? ).returns( false )
    assert !detector.detect_colour?( img, detector ).nil?
  end

  def test_should_detect_colour_if_density_reached
    detector = build_detector
    img = mock( "img" )
    img.stubs( :pixel_is_colour? ).returns( true )
    detector.expects( :density_reached? ).returns( true )
    assert detector.detect_colour?( img, detector )
  end

  def test_should_not_detect_colour_if_density_not_reached
    detector = build_detector
    img = mock( "img" )
    img.stubs( :pixel_is_colour? ).returns( true )
    detector.expects( :density_reached? ).returns( false )
    assert !detector.detect_colour?( img, detector )
  end

  def test_should_correctly_observe_offset_on_x_axis
    size = 1
    offset = 2
    real_index = size - 1 + offset
    detector = build_detector( :size => size, :offset => offset, :axis => :x )
    img = mock( "img" )
    img.expects( :pixel_is_colour? ).once.with { |*args| args[1] == real_index }
    detector.detect_colour?( img, detector )
  end

  def test_should_correctly_observe_offset_on_y_axis
    size = 1
    offset = 2
    real_index = size - 1 + offset
    detector = build_detector( :size => size, :offset => offset, :axis => :y )
    img = mock( "img" )
    img.expects( :pixel_is_colour? ).once.with { |*args| args[2] == real_index }
    detector.detect_colour?( img, detector )
  end

end
