class DetectBoundaryTest < ActiveSupport::TestCase

  #-- TODO: be able to run these tests with various detector options
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

  def test_should_return_nil_if_we_run_out_of_image
    detector = build_detector
    img = build_image( 0 )
    Chunking::Detector::Run.stubs( :new )
    assert_equal nil, detector.detect_boundary( img )
  end

  def test_should_change_state_on_detect_colour
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image
    run = build_run( detector, img )
    state = mock( "state" )
    detector.expects( :detect_colour? ).once.returns( state )
    assert_not_equal state, run.state
    detector.detect_boundary( img )
    assert_equal state, run.state
  end
    
  def test_should_increment_runs_tolerance_counter_when_state_changes
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image( 2 )
    run = build_run( detector, img )
    # fails first time
    # TODO: is this expecting once more than one expected mock behavior?
    run.expects( :state_changed? ).once.returns( false )
    run.expects( :state_changed? ).once.returns( true )
    run.expects( :increment_tolerance_counter ).once
    detector.detect_boundary( img )
  end

  def test_should_reset_runs_tolerance_when_state_changes_back
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image( 2 )
    run = build_run( detector, img )
    run.expects( :state_changed? ).once.returns( true )
    run.expects( :state_changed? ).once.returns( false )
    run.expects( :reset_tolerance_counter ).once
    detector.detect_boundary( img )
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

  def test_should_not_include_tolerance_in_boundary_index
    tolerance = 99
    detector = build_detector( :tolerance => tolerance )
    detector.stubs( :detect_colour? )
    img = build_image
    build_run( detector, img ).expects( :tolerance_reached? ).once.with( tolerance ).returns( true )
    assert result = detector.detect_boundary( img )
    assert_equal -tolerance, result.index
  end

  #-- TODO: these tests (if/if not) could be combined
  def test_should_detect_if_tolerance_reached
    tolerance = 99
    detector = build_detector( :tolerance => tolerance )
    detector.stubs( :detect_colour? )
    img = build_image
    build_run( detector, img ).expects( :tolerance_reached? ).once.with( tolerance ).returns( true )
    assert result = detector.detect_boundary( img )
    assert_equal Chunking::Boundary, result.class
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

  #-- TODO: test_should_not_alter_original_image_to_invert_direction
  def test_should_not_invert_image_to_invert_direction
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image
    img.expects( :invert ).never
    detector.detect_boundary( img, 0, false )
  end
    
end
