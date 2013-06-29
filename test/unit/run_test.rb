class RunTest < ActiveSupport::TestCase

  # TODO: need to test these methods
  def build_run
    Chunking::Detector::Run.stubs( :determine_initial_state )
    run = Chunking::Detector::Run.new( nil, nil )
  end

  def test_should_set_counter_to_zero
    assert_equal 0, build_run.tolerance_counter
  end

  def test_method_increment_tolerance_counter
    run = build_run
    assert_equal 0, run.tolerance_counter
    run.increment_tolerance_counter
    assert_equal 1, run.tolerance_counter
  end

  def test_initial_state_and_state_are_set_on_initialisation
    initial_state = mock( "initial_state" )
    Chunking::Detector::Run.expects( :determine_initial_state ).returns( initial_state )
    run = Chunking::Detector::Run.new( nil, nil )
    assert_equal initial_state, run.initial_state
    assert_equal initial_state, run.state
  end
  
  def test_method_state_changed?
    initial_state = mock( "initial_state" )
    new_state = mock( "new_state" )
    Chunking::Detector::Run.expects( :determine_initial_state ).returns( initial_state )
    run = Chunking::Detector::Run.new( nil, nil )
    assert !run.state_changed?
    run.state = new_state
    assert run.state_changed?
    assert_equal new_state, run.state
  end

  def test_method_tolerance_reached?
    run = build_run
    run.stubs( :tolerance_counter ).returns( 1 )
    assert_equal 1, run.tolerance_counter
    assert run.tolerance_reached?( 0 )
    assert !run.tolerance_reached?( 1 )
    assert !run.tolerance_reached?( 2 )
  end
end
