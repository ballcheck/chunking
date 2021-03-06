require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectBoundaryTest < TestCase

    # NOTE: tests specifically related to the Detector#detector_boundary method

    #def test_should_retrieve_image
    #  image = mock( "image" )
    #  detector = build_detector
    #  retrieved_image = build_image( 0 )
    #  detector.expects( :retrieve_image ).once.returns( retrieved_image )
    #  detector.detect_boundary( image )
    #end
    #  
    #def test_should_create_run_correctly
    #  img = build_image( 0 )
    #  detector = build_detector
    #  start_index = 0
    #  run = mock( "run" )
    #  Detector::Run.expects( :new ).once.returns( run )
    #  detector.detect_boundary( img, start_index )
    #  assert_equal [ run ], detector.runs
    #end

    #def test_runs_should_persist
    #  img = build_image( 0 )
    #  detector = build_detector
    #  start_index = 0
    #  run1 = mock( "run1" )
    #  run2 = mock( "run2" )
    #  Detector::Run.expects( :new ).times( 2 ).returns( run1, run2 )
    #  detector.detect_boundary( img, start_index )
    #  detector.detect_boundary( img, start_index )
    #  assert_equal [ run1, run2 ], detector.runs
    #end

    #def test_should_return_nil_if_we_run_out_of_image
    #  img = build_image( 0 )
    #  detector = build_detector
    #  Detector::Run.stubs( :new )
    #  assert_equal nil, detector.detect_boundary( img )
    #end

    #def test_should_stop_checking_when_detected
    #  row_count = 5
    #  img = build_image( row_count )
    #  detector = build_detector
    #  detector.expects( :detect_colour? ).times( 2 ).returns( build_result( true ), build_result( false ) )
    #  assert detector.detect_boundary( img )
    #end

    #def test_should_correctly_observe_starting_index
    #  row_count = 5
    #  img = build_image( row_count )
    #  detector = build_detector
    #  starting_index = 1
    #  detector.expects( :detect_colour? ).times( row_count - starting_index ).returns( build_result( false ) )
    #  assert !detector.detect_boundary( img, starting_index )
    #end

    #def test_should_not_include_tolerance_counter_in_boundary_index
    #  img = build_image
    #  tolerance_counter = 99
    #  detector = build_detector
    #  run = build_run
    #  detector.stubs( :create_run ).returns( run )
    #  detector.expects( :tolerance_exceeded? ).once.returns( true )
    #  run.stubs( :tolerance_counter ).returns( tolerance_counter )
    #  assert result = detector.detect_boundary( img )
    #  assert_equal -tolerance_counter+1, result.index
    #end

    #def test_should_detect_if_tolerance_exceeded
    #  img = build_image
    #  detector = build_detector
    #  detector.expects( :tolerance_exceeded? ).once.returns( true )
    #  assert result = detector.detect_boundary( img )
    #  assert_equal Boundary, result.class
    #end
    #  
    #def test_should_not_detect_if_tolerance_not_reached
    #  img = build_image
    #  detector = build_detector
    #  detector.expects( :detect_colour? ).returns( build_result( false ) )
    #  detector.expects( :tolerance_exceeded? ).once.returns( false )
    #  assert !detector.detect_boundary( img )
    #end

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
