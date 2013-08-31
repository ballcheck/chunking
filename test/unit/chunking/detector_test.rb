module Chunking
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
      detector = build_detector
      img = mock( "img" )
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
      
    def test_method_density_reached?
      detector = build_detector( :density => 1 )
      assert !detector.send( :density_reached?, 0 )
      assert detector.send( :density_reached?, 1 )
      assert detector.send( :density_reached?, 2 )
    end


    #--------------------------------------------
    # aliases, class versions of instance methods
    #--------------------------------------------

    def test_should_call_detect_colour_as_class_method
      detector = build_detector
      args = stub( "args" )
      img = stub( "img" )
      index = stub( "index" )
      Detector.expects( :new ).once.with( args ).returns( detector )
      detector.expects( :detect_colour? ).once.with( img, index )
      Detector.detect_colour? img, index, args
    end

    def test_should_alias_colour_with_color
      # TODO: this is not a conclusive test.
      # TODO: is this kind of test necessary?
      assert Detector.instance_method( :detect_color? ) == Detector.instance_method( :detect_colour? )
      assert Detector.method( :detect_color? ) == Detector.method( :detect_colour? )
    end



    #---------------
    # library methods
    #---------------
    #-- TODO: these methods are in the wrong place anyway

    def test_method_is_percent_string
      # TODO: are these kind of tests really needed?
      assert Detector.send( :is_percent_string?, "1%" )
      assert Detector.send( :is_percent_string?, "10%" )
      assert Detector.send( :is_percent_string?, "1.1%" )
      assert !Detector.send( :is_percent_string?, "a1%" )
      assert !Detector.send( :is_percent_string?, "10" )
      assert !Detector.send( :is_percent_string?, 10 )
    end

    def test_method_apply_percent_string
      assert_equal 0.09, Detector.send( :apply_percent_string, 9, "1%" )
      assert_equal 9.9, Detector.send( :apply_percent_string, 99, "10%" )
      assert_equal 10.989, Detector.send( :apply_percent_string, 999, "1.1%" )
    end

  end
end
