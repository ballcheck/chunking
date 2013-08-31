require File.expand_path( "../test_helper.rb", __FILE__ )
module Chunking
  class DetectorRunTest < TestCase

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
      DetectorRun.any_instance.expects( :determine_initial_state ).returns( initial_state )
      run = DetectorRun.new( nil, nil )
      assert_equal initial_state, run.initial_state
      assert_equal initial_state, run.state
    end

    def test_method_determine_initial_state
      image = stub( "image", :create_mask => nil )
      start_index = stub( "start_index" )
      state = stub( "state" )
      detector = mock( "detector" )
      detector.stubs( :detect_colour? ).returns( state )
      run = DetectorRun.new( detector, image ) # triggers determine_initial_state once
      assert_equal state, run.send( :determine_initial_state, detector, image, start_index )
    end
    
    def test_method_state_changed?
      initial_state = mock( "initial_state" )
      new_state = mock( "new_state" )
      DetectorRun.any_instance.expects( :determine_initial_state ).returns( initial_state )
      run = DetectorRun.new( nil, nil )
      assert !run.state_changed?
      run.state = new_state
      assert run.state_changed?
      assert_equal new_state, run.state
    end

    def test_method_tolerance_reached?
      run = build_run
      run.stubs( :tolerance_counter ).returns( 1 )
      assert_equal 1, run.tolerance_counter
      detector = mock( "detector" )
      detector.expects( :tolerance ).times( 3 ).returns( 0, 1, 2 )
      run.stubs( :detector ).returns( detector )
      assert run.tolerance_reached?
      assert !run.tolerance_reached?
      assert !run.tolerance_reached?
    end

    def test_annotation_mask_is_set_on_initialisation
      mask = mock( "mask" )
      DetectorRun.any_instance.expects( :create_annotation_mask ).returns( mask )
      DetectorRun.any_instance.stubs( :determine_initial_state )
      run = DetectorRun.new( nil, nil )
      assert_equal mask, run.annotation_mask
    end
  end
end
