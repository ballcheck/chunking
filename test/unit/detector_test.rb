class DetectorTest < ActiveSupport::TestCase

  # ---------------
  # initialisation
  # ---------------

  def test_should_detect_black_by_default
    detector = Chunking::Detector.new
    assert_equal Chunking::Detector::RGB_BLACK, detector.rgb
  end

  # --------
  # methods
  # --------

  def test_method_detect_nth_boundary
    detector = build_detector
    img = mock( "img" )
    invert = mock( "invert" )
    start_index = 0
    first_index = 1
    second_index = 5
    # 'n' times
    n = 2
    detector.expects( :detect_boundary ).times( 1 ).with( img, start_index, invert ).returns( first_index )
    detector.expects( :detect_boundary ).times( 1 ).with( img, start_index + first_index, invert ).returns( second_index )
    final_index = detector.detect_nth_boundary( img, n, start_index, invert )
    assert_equal second_index, final_index
  end

  def test_method_detect_nth_boundary_should_return_nil_when_boundaries_exhausted
    detector = build_detector
    n = 5
    detector.expects( :detect_boundary ).times( 1 ).returns( false )
    boundary = detector.detect_nth_boundary( nil, n )
    assert_equal nil, boundary
  end
    
  def test_method_density_reached?
    detector = build_detector( :density => 1 )
    assert !detector.send( :density_reached?, 0 )
    assert detector.send( :density_reached?, 1 )
    assert detector.send( :density_reached?, 2 )
  end


  # --------------------------------------------
  # aliases, class versions of instance methods
  # --------------------------------------------

  def test_should_call_detect_colour_as_class_method
    detector = build_detector
    args = stub( "args" )
    img = stub( "img" )
    index = stub( "index" )
    Chunking::Detector.expects( :new ).once.with( args ).returns( detector )
    detector.expects( :detect_colour? ).once.with( img, index )
    Chunking::Detector.detect_colour? img, index, args
  end

  # TODO: this is not a conclusive test.
  def test_should_alias_colour_with_color
    assert Chunking::Detector.instance_method( :detect_color? ) == Chunking::Detector.instance_method( :detect_colour? )
    assert Chunking::Detector.method( :detect_color? ) == Chunking::Detector.method( :detect_colour? )
  end



  # ---------------
  # library methods
  # ---------------

  # TODO: are these kind of tests really needed?
  def test_method_is_percent_string
    assert Chunking::Detector.send( :is_percent_string?, "1%" )
    assert Chunking::Detector.send( :is_percent_string?, "10%" )
    assert Chunking::Detector.send( :is_percent_string?, "1.1%" )
    assert !Chunking::Detector.send( :is_percent_string?, "a1%" )
    assert !Chunking::Detector.send( :is_percent_string?, "10" )
    assert !Chunking::Detector.send( :is_percent_string?, 10 )
  end

  def test_method_apply_percent_string
    assert_equal 0.09, Chunking::Detector.send( :apply_percent_string, 9, "1%" )
    assert_equal 9.9, Chunking::Detector.send( :apply_percent_string, 99, "10%" )
    assert_equal 10.989, Chunking::Detector.send( :apply_percent_string, 999, "1.1%" )
  end
    

end
