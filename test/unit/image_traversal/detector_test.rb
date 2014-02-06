require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectorTest < TestCase

    #---------------
    # initialisation
    #---------------

    def test_should_detect_black_by_default
      detector = Detector.new
      assert_equal Detector::RGB_BLACK, detector.colour
    end

    #--------
    # methods
    #--------

    def test_method_detect_nth_boundary
      img = mock( "img" )
      detector = build_detector( img )
      invert = mock( "invert" )
      start_index = 0
      first_index = 1
      second_index = 5
      first_boundary = Boundary.new( nil, first_index )
      second_boundary = Boundary.new( nil, second_index )
      # 'n' times
      n = 2
      detector.expects( :detect_boundary ).times( 1 ).with( img, start_index, invert, false ).returns( first_boundary )
      detector.expects( :detect_boundary ).times( 1 ).with( img, start_index + first_index, invert, false ).returns( second_boundary )
      final_index = detector.detect_nth_boundary( img, n, start_index, invert ).index
      assert_equal second_index, final_index
    end

    def test_method_detect_nth_boundary_should_return_nil_when_boundaries_exhausted
      detector = build_detector
      n = 5
      detector.expects( :detect_boundary ).times( 1 ).returns( false )
      boundary = detector.detect_nth_boundary( nil, n )
      assert_equal nil, boundary
    end

    def test_method_detect_nth_boundary_should_create_n_runs
      n = 3
      run1 = build_run
      run2 = build_run
      run3 = build_run
      DetectorRun.stubs( :new ).returns( run1, run2, run3 )
      DetectorRun.any_instance.stubs( :tolerance_reached? => true )
      image = build_image
      detector = build_detector( image )
      detector.detect_nth_boundary( image, n )
      assert_equal n, detector.runs.length
    end
      
      
    def test_method_density_reached?
      detector = build_detector( :density => 1 )
      assert !detector.send( :density_reached?, 0 )
      assert detector.send( :density_reached?, 1 )
      assert detector.send( :density_reached?, 2 )
    end

    def test_method_annotate_image
      x = stub( "x" )
      y = stub( "y" )
      colour = stub( "colour" )

      image = stub( "image" )
      image.expects( :set_pixel_colour ).with( x, y, colour )

      detector = build_detector( image )
      detector.annotate_image( image, x, y, colour )
    end

    #--------------------------------------------
    # aliases, class versions of instance methods
    #--------------------------------------------

    def test_should_call_detect_colour_as_class_method
      img = stub( "img" )
      detector = build_detector( img )
      args = stub( "args" )
      index = stub( "index" )
      Detector.expects( :new ).once.with( args ).returns( detector )
      detector.expects( :detect_colour? ).once.with( img, index )
      Detector.detect_colour? img, index, args
    end

    def test_should_alias_colour_with_color
      assert Detector.instance_method( :detect_color? ) == Detector.instance_method( :detect_colour? )
      assert Detector.method( :detect_color? ) == Detector.method( :detect_colour? )
    end

  end
end
