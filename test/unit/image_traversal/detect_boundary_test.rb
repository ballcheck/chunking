require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectBoundaryTest < TestCase

    def test_should_retrieve_image
      image = mock( "image" )
      detector = build_detector( image )
      retrieved_image = build_image( 0 )
      detector.expects( :retrieve_image ).once.returns( retrieved_image )
      detector.detect_boundary( image )
    end
      
    def test_should_create_run_correctly
      img = build_image( 0 )
      detector = build_detector( img )
      start_index = mock( "start_index", :to_i => 0 )
      run = mock( "run" )
      DetectorRun.expects( :new ).once.with( detector, img, start_index ).returns( run )
      detector.detect_boundary( img, start_index )
      assert_equal [ run ], detector.runs
    end

    def test_runs_should_persist
      img = build_image( 0 )
      detector = build_detector( img )
      start_index = stub( "start_index", :to_i => 0 )
      run1 = mock( "run1" )
      run2 = mock( "run2" )
      DetectorRun.expects( :new ).times( 2 ).with( detector, img, start_index ).returns( run1, run2 )
      detector.detect_boundary( img, start_index )
      detector.detect_boundary( img, start_index )
      assert_equal [ run1, run2 ], detector.runs
    end

    def test_should_return_nil_if_we_run_out_of_image
      img = build_image( 0 )
      detector = build_detector( img )
      DetectorRun.stubs( :new )
      assert_equal nil, detector.detect_boundary( img )
    end

    def test_should_change_state_on_detect_colour
      img = build_image
      detector = build_detector( img )
      detector.stubs( :detect_colour? )
      run = build_run( detector, img )
      state = mock( "state" )
      detector.expects( :detect_colour? ).once.returns( state )
      assert_not_equal state, run.state
      detector.detect_boundary( img )
      assert_equal state, run.state
    end
      
    def test_should_increment_runs_tolerance_counter_when_state_changes
      img = build_image( 2 )
      detector = build_detector( img )
      detector.stubs( :detect_colour? )
      run = build_run( detector, img )
      run.expects( :state_changed? ).times( 2 ).returns( false, true )
      run.expects( :increment_tolerance_counter ).once
      detector.detect_boundary( img )
    end

    def test_should_reset_runs_tolerance_when_state_changes_back
      img = build_image( 2 )
      detector = build_detector( img )
      detector.stubs( :detect_colour? )
      run = build_run( detector, img )
      run.expects( :state_changed? ).times( 2 ).returns( false, true )
      run.expects( :reset_tolerance_counter ).once
      detector.detect_boundary( img )
    end

    def test_should_check_all_rows
      row_count = 5
      img = build_image( row_count )
      detector = build_detector( img )
      detector.stubs( :detect_colour? )
      build_run( detector, img ).expects( :state_changed? ).times( row_count ).returns( false )
      detector.detect_boundary( img )
    end

    def test_should_stop_checking_when_detected
      row_count = 5
      img = build_image( row_count )
      detector = build_detector( img )
      detector.stubs( :detect_colour? )
      build_run( detector, img ).expects( :state_changed? ).once.returns( true )
      assert detector.detect_boundary( img )
    end

    def test_should_correctly_observe_starting_index
      row_count = 5
      img = build_image( row_count )
      detector = build_detector( img )
      detector.stubs( :detect_colour? )
      starting_index = 1
      build_run( detector, img ).expects( :state_changed? ).times( row_count - starting_index ).returns( false )
      assert !detector.detect_boundary( img, starting_index )
    end

    def test_should_not_include_tolerance_in_boundary_index
      img = build_image
      tolerance = 99
      detector = build_detector( img, :tolerance => tolerance )
      detector.stubs( :detect_colour? )
      build_run( detector, img ).expects( :tolerance_reached? ).once.returns( true )
      assert result = detector.detect_boundary( img )
      assert_equal -tolerance, result.index
    end

    def test_should_detect_if_tolerance_reached
      img = build_image
      detector = build_detector( img )
      detector.stubs( :detect_colour? )
      build_run( detector, img ).expects( :tolerance_reached? ).once.returns( true )
      assert result = detector.detect_boundary( img )
      assert_equal Boundary, result.class
    end
      
    def test_should_not_detect_if_tolerance_not_reached
      img = build_image
      detector = build_detector( img )
      detector.stubs( :detect_colour? )
      build_run( detector, img ).expects( :tolerance_reached? ).once.returns( false )
      assert !detector.detect_boundary( img )
    end

    def test_should_invert_image_to_invert_direction
      img = build_image
      detector = build_detector( img )
      detector.stubs( :detect_colour? )
      img.expects( :invert ).once.with( detector.axis ).returns( img )
      detector.detect_boundary( img, 0, true )
    end

    def test_should_not_alter_original_image_to_invert_direction
      img = build_image
      detector = build_detector( img )
      detector.stubs( :detect_colour? )
      img_copy = build_image
      img.stubs( :invert ).returns( img_copy )
      img.expects( :invert! ).never
      img_copy.expects( :invert! ).once.with( detector.axis )
      detector.detect_boundary( img, 0, true )
      assert_equal img_copy, detector.runs.last.image
    end


    def test_should_not_invert_image_to_invert_direction
      img = build_image
      detector = build_detector( img )
      detector.stubs( :detect_colour? )
      img.expects( :invert ).never
      detector.detect_boundary( img, 0, false )
    end
      
    #def test_benchmark_compare_colours?
    #  n = 100000
    #  Benchmark.bm { |x|
    #    px = Magick::Pixel.new( 0, 0, 0 )

    #    x.report( "fcmp" ){
    #      n.times do
    #        px.fcmp( px )
    #      end
    #    }

    #    x.report( "compare_colours?" ) {
    #      n.times do
    #        Image::Base.compare_colours?( [ 0, 0, 0 ], [ 0, 0, 0 ] )
    #      end
    #    }

    #  }
    #end

      
  end
end
