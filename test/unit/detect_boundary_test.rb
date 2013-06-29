class DetectBoundaryTest < ActiveSupport::TestCase

  # TODO: be able to run these tests with various detector options
  def build_run( *args )
    run = Chunking::Detector::Run.new( *args )
    # ensure that when a run is created in 'detect_boundary' this run (the one
    # that was created with *args) is returned
    Chunking::Detector::Run.stubs( :new ).once.returns( run )
    return run
  end

  def build_image( size = 1 )
    img = mock( "img" )
    img.stubs( :size ).returns( size )
    return img
  end
    
  def test_should_create_run_correctly
    detector = build_detector
    img = build_image( 0 )
    start_index = mock( "start_index", :to_i => 0 )
    Chunking::Detector::Run.expects( :new ).once.with( detector, img, start_index )
    detector.detect_boundary( img, start_index )
  end

  def test_should_detect_if_state_changed
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image
    build_run( detector, img ).expects( :state_changed? ).once.returns( true )
    assert detector.detect_boundary( img )
  end

  def test_should_not_detect_if_state_not_changed
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image
    build_run( detector, img ).expects( :state_changed? ).once.returns( false )
    assert !detector.detect_boundary( img )
  end

  def test_should_check_all_rows
    detector = build_detector
    detector.stubs( :detect_colour? )
    row_count = 5
    img = build_image( row_count )
    build_run( detector, img ).expects( :state_changed? ).times( row_count ).returns( false )
    detector.detect_boundary( img )
  end
    
  def test_should_stop_checking_when_detected
    detector = build_detector
    detector.stubs( :detect_colour? )
    row_count = 5
    img = build_image( row_count )
    build_run( detector, img ).expects( :state_changed? ).once.returns( true )
    assert detector.detect_boundary( img )
  end

  def test_should_correctly_observe_starting_index
    detector = build_detector
    detector.stubs( :detect_colour? )
    row_count = 5
    starting_index = 1
    img = build_image( row_count )
    build_run( detector, img ).expects( :state_changed? ).times( row_count - starting_index ).returns( false )
    assert !detector.detect_boundary( img, starting_index )
  end

  def test_should_detect_if_tolerance_reached
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image
    build_run( detector, img ).expects( :tolerance_reached? ).once.with( detector.tolerance ).returns( true )
    assert detector.detect_boundary( img )
  end
    
  def test_should_not_detect_if_tolerance_not_reached
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image
    build_run( detector, img ).expects( :tolerance_reached? ).once.returns( false )
    assert !detector.detect_boundary( img )
  end

  def test_should_invert_image_to_invert_direction
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image
    img.expects( :invert ).once.with( detector.axis ).returns( img )
    detector.detect_boundary( img, 0, true )
  end
    
  def test_should_not_invert_image_to_invert_direction
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image
    img.expects( :invert ).never
    detector.detect_boundary( img, 0, false )
  end
    
end
