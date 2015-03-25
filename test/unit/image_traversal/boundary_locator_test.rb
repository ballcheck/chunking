require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class BoundaryLocatorTest < TestCase

    # NOTE: Tests moved here from DetectorTest and reworked

    # ---------------
    # private methods
    # ---------------

    def test_method_determine_last_line_index_y_axis
      detector = build_detector( :axis => :y )
      locator = build_boundary_locator( detector )

      # create image of random size
      width, height = (1..99).to_a.sample( 2 )
      img = ImageTraversal.image_adapter_class.factory( width, height )

      # then...
      assert_equal width - 1, locator.send( :determine_last_line_index, img )
    end

    def test_method_determine_last_line_index_x_axis
      detector = build_detector( :axis => :x )
      locator = build_boundary_locator( detector )

      # create image of random size
      width, height = (1..99).to_a.sample( 2 )
      img = ImageTraversal.image_adapter_class.factory( width, height )

      # then...
      assert_equal height - 1, locator.send( :determine_last_line_index, img )
    end

    def test_method_determine_absolute_line_index
      detector = build_detector
      locator = build_boundary_locator( detector )

      # args with random values.
      last_line_index, line_index = (0..99).to_a.sample( 2 )
   
      # then...
      # if not inverting direction, just use line index.
      assert_equal line_index, locator.send( :determine_absolute_line_index, false, last_line_index, line_index )

      # if inverting, factor in image size.
      assert_equal ( last_line_index - line_index ), locator.send( :determine_absolute_line_index, true, last_line_index, line_index )
    end

    def test_method_determine_boundary
      detector = build_detector
      locator = build_boundary_locator( detector )
      run = build_run

      # args with random values.
      line_index = (0..99).to_a.sample
      run_tolerance_counter = (0..99).to_a.sample

      # frig run.tolerance_counter
      run.stubs( :tolerance_counter ).returns( run_tolerance_counter )

      # then...
      locator.stubs( :tolerance_exceeded? ).with( run_tolerance_counter ).returns( true )
      boundary = locator.send( :determine_boundary, line_index, run )
      assert_equal detector.axis, boundary.axis
      assert_equal ( line_index - run.tolerance_counter + 1 ), boundary.index

      # also...
      locator.stubs( :tolerance_exceeded? ).with( run_tolerance_counter ).returns( false )
      assert_equal nil, locator.send( :determine_boundary, line_index, run )
    end

    def test_method_retrieve_image
      detector = build_detector
      locator = build_boundary_locator( detector )

      # image of the class ImageTraversal.image_adapter_class
      img = build_image

      # any other image value
      non_img = stub
      new_img = stub
      ImageTraversal.image_adapter_class.stubs( :factory ).with( non_img ).returns( new_img )

      # then...
      # an img of image_adapter_class comes back untouched
      assert_equal img, locator.send( :retrieve_image, img )

      # but anything else goes to the factory
      assert_equal new_img, locator.send( :retrieve_image, non_img )
    end

    def test_method_tolerance_exceeded
      # detector with random tolerance
      tolerance = (0..99).to_a.sample
      detector = build_detector( :tolerance => tolerance )
      locator = build_boundary_locator( detector )

      # then...
      assert_equal false, locator.send( :tolerance_exceeded?, tolerance-1 )
      assert_equal false, locator.send( :tolerance_exceeded?, tolerance )
      assert_equal true, locator.send( :tolerance_exceeded?, tolerance+1 )
    end


  

    # NOTE: Tests moved here from DetectBoundaryTest and reworked
    # Specifically testing method BoundaryLocator#locate_boundary

    # TODO: some of these tests are poor and most are really just testing the implementation.
    # Clearly not TDD!

    def test_should_create_run_correctly
      # Given
      # a zero size image so we don't enter the each-do block and have to
      # stub absolutely everything.
      img = build_image( 0 )
      detector = build_detector
      locator = build_boundary_locator( detector )

      # get a handle on newly created run
      run = mock( "run" )
      Detector::Run.expects( :new ).once.returns( run )

      # When
      locator.locate_boundary( img )

      # Then
      assert_equal [ run ], detector.runs
    end

    def test_runs_should_persist
      # Given
      img = build_image( 0 )
      detector = build_detector
      locator = build_boundary_locator( detector )

      # get a handle on new runs
      run1 = mock( "run1" )
      run2 = mock( "run2" )
      Detector::Run.expects( :new ).times( 2 ).returns( run1, run2 )

      # When
      locator.locate_boundary( img )
      locator.locate_boundary( img )

      # Then
      assert_equal [ run1, run2 ], detector.runs
    end

    def test_should_return_nil_if_we_run_out_of_image
      # Given
      img = build_image( 0 )
      detector = build_detector
      locator = build_boundary_locator( detector )

      # get a handle on newly created run
      run = mock( "run" )
      Detector::Run.expects( :new ).once.returns( run )

      # When
      nil_boundary = locator.locate_boundary( img )

      # Then
      assert_equal nil, nil_boundary

      # check the run went through ok
      assert_equal [ run ], detector.runs
    end

    def test_should_stop_checking_when_detected
      # Given
      row_count = 5
      img = build_image( row_count )
      detector = build_detector
      locator = build_boundary_locator( detector )

      # When / # Then
      # ensure we only check 2 of the 5 rows for efficiency
      detector.expects( :detect_colour? ).times( 2 ).returns( build_result( true ), build_result( false ) )
      locator.locate_boundary( img )
    end

    def test_should_correctly_observe_starting_index
      # Given
      row_count = 5
      img = build_image( row_count )
      detector = build_detector
      locator = build_boundary_locator( detector )
      starting_index = 1

      # When / # Then
      # ensure we check the right number of times based on starting_index
      detector.expects( :detect_colour? ).times( row_count - starting_index ).returns( build_result( false ) )
      locator.locate_boundary( img, starting_index )

      # TODO: we only test detect_colour? is called the requisite number of times, not what it's
      # called with. Although this test is a bit pointless.
    end

    def test_should_not_include_tolerance_counter_in_boundary_index
      # Given
      img = build_image
      tolerance_counter = 99
      detector = build_detector
      locator = build_boundary_locator( detector )

      # get a handle on new runs
      run = build_run
      run.stubs( :tolerance_counter ).returns( tolerance_counter )
      locator.stubs( :create_run ).returns( run )

      # When
      locator.expects( :tolerance_exceeded? ).once.returns( true )
      result = locator.locate_boundary( img )

      # Then
      assert_equal -tolerance_counter+1, result.index
    end

    def test_should_detect_if_tolerance_exceeded
      # Given
      img = build_image
      detector = build_detector
      locator = build_boundary_locator( detector )

      # When
      locator.expects( :tolerance_exceeded? ).once.returns( true )
      result = locator.locate_boundary( img )

      # Then
      assert_equal Boundary, result.class
    end
      
    def test_should_not_detect_if_tolerance_not_reached
      # Given
      img = build_image
      detector = build_detector
      locator = build_boundary_locator( detector )

      # When
      detector.expects( :detect_colour? ).returns( build_result( false ) )
      locator.expects( :tolerance_exceeded? ).once.returns( false )
      nil_boundary = locator.locate_boundary( img )

      # Then
      assert_nil nil_boundary
    end

    # Removed as not testing anything
    #def test_should_retrieve_image
    #  image = mock( "image" )
    #  detector = build_detector
    #  locator = build_boundary_locator( detector )

    #  retrieved_image = build_image( 0 )
    #  detector.expects( :retrieve_image ).once.returns( retrieved_image )
    #  detector.detect_boundary( image )
    #end
      


  end
end
