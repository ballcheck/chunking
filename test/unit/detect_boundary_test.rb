require "test_helper"

class DetectBoundaryTest < ActiveSupport::TestCase

  # TODO: be able to run these tests with various detector options
  def build_run( detector, img, ind = 0 )
    run = Chunking::Detector::Run.new( detector, img, ind )
    Chunking::Detector::Run.expects( :new ).once.returns( run )
    return run
  end

  def build_image( detector, size = 1 )
    img = mock( "img" )
    img.expects( :size ).with( detector.axis ).returns( size )
    return img
  end
    
  def test_should_detect_if_state_changed
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image( detector )
    build_run( detector, img ).expects( :state_changed? ).once.returns( true )
    assert detector.detect_boundary( img )
  end

  def test_should_not_detect_if_state_not_changed
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image( detector )
    build_run.expects( :state_changed? ).once.returns( false )
    assert !detector.detect_boundary( img )
  end

  def test_should_check_all_rows
    detector = build_detector
    detector.stubs( :detect_colour? )
    row_count = 5
    img = build_image( detector, row_count )
    build_run.expects( :state_changed? ).times( row_count ).returns( false )
    detector.detect_boundary( img )
  end
    
  def test_should_stop_checking_when_detected
    detector = build_detector
    detector.stubs( :detect_colour? )
    row_count = 5
    img = build_image( detector, row_count )
    build_run.expects( :state_changed? ).once.returns( true )
    assert detector.detect_boundary( img )
  end

  def test_should_correctly_observe_starting_index
    detector = build_detector
    detector.stubs( :detect_colour? )
    row_count = 5
    starting_index = 1
    img = build_image( detector, row_count )
    build_run.expects( :state_changed? ).times( row_count - starting_index ).returns( false )
    assert !detector.detect_boundary( img, starting_index )
  end

  def test_should_detect_if_tolerance_reached
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image( detector )
    build_run.expects( :tolerance_reached? ).once.with( detector.tolerance ).returns( true )
    assert detector.detect_boundary( img )
  end
    
  def test_should_not_detect_if_tolerance_not_reached
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image( detector )
    build_run.expects( :tolerance_reached? ).once.returns( false )
    assert !detector.detect_boundary( img )
  end

  def test_should_invert_image_to_invert_direction
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = stub( "img", :size => 0 )
    img.expects( :invert ).once.with( detector.axis ).returns( img )
    detector.detect_boundary( img, nil, true )
  end
    
  def test_should_not_invert_image_to_invert_direction
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = stub( "img", :size => 0 )
    img.expects( :invert ).never
    detector.detect_boundary( img, nil, false )
  end
    
end
