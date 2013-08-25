class RunTest < ActiveSupport::TestCase

  def build_run( detector = nil, image = nil )
    # TODO: this is only a class method so it can be stubbed.
    Chunking::DetectorRun.stubs( :determine_initial_state )
    run = Chunking::DetectorRun.new( detector, image )
  end

  def test_should_set_counter_to_zero
    assert_equal 0, build_run.tolerance_counter
  end

  def test_method_tolerance
    tolerance = mock( "tolerance" )
    detector = mock( :tolerance => tolerance )
    run = build_run( detector )
    assert_equal run.send( :tolerance ), tolerance
  end
    
  def test_method_increment_tolerance_counter
    run = build_run
    assert_equal 0, run.tolerance_counter
    run.increment_tolerance_counter
    assert_equal 1, run.tolerance_counter
  end

  def test_initial_state_and_state_are_set_on_initialisation
    initial_state = mock( "initial_state" )
    Chunking::DetectorRun.expects( :determine_initial_state ).returns( initial_state )
    run = Chunking::DetectorRun.new( nil, nil )
    assert_equal initial_state, run.initial_state
    assert_equal initial_state, run.state
  end

  def test_method_determine_initial_state
    detector = mock( "detector" )
    image = mock( "image" )
    start_index = mock( "start_index" )
    state = mock( "state" )
    detector.expects( :detect_colour? ).with( image, start_index ).returns( state )
    assert_equal state, ::Chunking::DetectorRun.determine_initial_state( detector, image, start_index )
  end
  
  def test_method_state_changed?
    initial_state = mock( "initial_state" )
    new_state = mock( "new_state" )
    Chunking::DetectorRun.expects( :determine_initial_state ).returns( initial_state )
    run = Chunking::DetectorRun.new( nil, nil )
    assert !run.state_changed?
    run.state = new_state
    assert run.state_changed?
    assert_equal new_state, run.state
  end

  def test_method_tolerance_reached?
    run = build_run
    run.stubs( :tolerance_counter ).returns( 1 )
    assert_equal 1, run.tolerance_counter
    run.stubs( :detector => stub( :tolerance => 0 ) )
    assert run.tolerance_reached?
    run.stubs( :detector => stub( :tolerance => 1 ) )
    assert !run.tolerance_reached?
    run.stubs( :detector => stub( :tolerance => 2 ) )
    assert !run.tolerance_reached?
  end
end
