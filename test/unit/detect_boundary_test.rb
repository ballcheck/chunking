class DetectBoundaryTest < ActiveSupport::TestCase

  # TODO: be able to run these tests with various detector options
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

  # works the same if starting on a colour and moving off.
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

  # TODO: these tests (if/if not) could be combined
  def test_should_detect_if_tolerance_reached
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image
    build_run( detector, img ).expects( :tolerance_reached? ).once.with( detector.tolerance ).returns( true )
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
    
  def test_should_not_invert_image_to_invert_direction
    detector = build_detector
    detector.stubs( :detect_colour? )
    img = build_image
    img.expects( :invert ).never
    detector.detect_boundary( img, 0, false )
  end
    


  # ----------------
  # functional tests
  # ----------------
  
  # NOTE: all these tests should move from off to on colour so we can later swap colours
  # TODO: run these test again, inverting the colour.
  # TODO: run these tests again, swapping image library
  # TODO: run all these again, inverting image
  # TODO: run all these again, swapping axis
  # TODO: move these out to a separate file
  def setup
    @axis = :x
  end

  def invert?
    false
  end

  def build_image_from_pixel_map( pixel_map )
    Chunking::Image::RMagickImage.new_from_pixel_map pixel_map
  end
  
  def test_start_index
    # given
    rgb = [10000, 10000, 10000]
    pixel_map = [
      [ nil, nil, nil, nil, nil ],
      [ rgb, rgb, rgb, rgb, rgb ],
      [ nil, nil, nil, nil, nil ],
      [ rgb, rgb, rgb, rgb, rgb ],
      [ nil, nil, nil, nil, nil ],
      [ nil, nil, nil, nil, nil ],
      [ rgb, rgb, rgb, rgb, rgb ],
      [ nil, nil, nil, nil, nil ]
    ]

    img = build_image_from_pixel_map pixel_map
    img = img.rotate( -90 ) if @axis == :y
    img = img.invert( @axis ) if invert?

    detector = Chunking::Detector.new( :axis => @axis, :size => 5, :rgb => rgb )

    # on first row
    assert_equal 1, detector.detect_boundary( img, 0, invert? ).index
    # where initial row is boundary
    assert_equal 3, detector.detect_boundary( img, 2, invert? ).index
    # jump a row to boundary
    assert_equal 6, detector.detect_boundary( img, 4, invert? ).index
    # same boundary different start
    assert_equal 6, detector.detect_boundary( img, 5, invert? ).index
    # last row
    assert_equal nil, detector.detect_boundary( img, 7, invert? )
  end

  
  def test_offset
    rgb = [10000, 10000, 10000]
    pixel_map = [
      [ nil, nil, nil, nil, nil ],
      [ rgb, nil, nil, nil, nil ],
      [ nil, rgb, nil, nil, nil ],
      [ nil, nil, rgb, nil, nil ],
      [ nil, nil, nil, rgb, nil ],
      [ nil, nil, nil, nil, rgb ]
    ]

    img = build_image_from_pixel_map pixel_map
    img = img.rotate( -90 ) if @axis == :y
# TODO: needed this because the map doesn't work as offset is from top, not bottom.
    img = img.invert( :x ) if @axis == :y
    img = img.invert( @axis ) if invert?

    size = img.size( @axis )

    # TODO: would be nice to use full size here, but it breaks if size extends outside image.
    size.times do |i|
       detector = Chunking::Detector.new( :axis => @axis, :offset => i, :size => size - i, :rgb => rgb )
# TODO: get rid of "0"
       assert_equal i+1,  detector.detect_boundary( img, 0, invert? ).index
    end
  end
  
  # TODO: what should happen when detector bigger than image?
  # TODO: rotate array to allow other axis test?
  def test_size
    rgb = [10000, 10000, 10000]
    pixel_map = [
      [ nil, nil, nil, nil, nil ],
      [ nil, nil, nil, nil, rgb ],
      [ nil, nil, nil, rgb, nil ],
      [ nil, nil, rgb, nil, nil ],
      [ nil, rgb, nil, nil, nil ],
      [ rgb, nil, nil, nil, nil ]
    ]

    img = build_image_from_pixel_map pixel_map
    img = img.rotate( -90 ) if @axis == :y
# TODO: needed this because the map doesn't work as offset is from top, not bottom.
    img = img.invert( :x ) if @axis == :y
    img = img.invert( @axis ) if invert?

    size = img.size( @axis )

    size.times do |i|
       detector = Chunking::Detector.new( :axis => @axis, :size => size - i, :rgb => rgb )
       assert_equal i+1, detector.detect_boundary( img, 0, invert? ).index
    end
  end

  def test_density
    rgb = [10000, 10000, 10000]
    pixel_map = [
      [ nil, nil, nil, nil, nil ],
      [ nil, nil, rgb, nil, nil ],
      [ nil, rgb, rgb, nil, nil ],
      [ nil, rgb, rgb, rgb, nil ],
      [ rgb, rgb, rgb, rgb, nil ],
      [ rgb, rgb, rgb, rgb, rgb ]
    ]

    img = build_image_from_pixel_map pixel_map
    img = img.rotate( -90 ) if @axis == :y
    img = img.invert( @axis ) if invert?

    size = img.size( @axis )

    size.times do |i|
       detector = Chunking::Detector.new( :axis => @axis, :density => i + 1, :size => size, :rgb => rgb )
       assert_equal i+1, detector.detect_boundary( img, 0, invert? ).index
    end
  end

  def test_tolerance
    rgb = [10000, 10000, 10000]
    pixel_map = [
      [ nil, nil, nil, nil, nil ],
      [ rgb, nil, nil, nil, nil ],
      [ nil, nil, nil, nil, rgb ],
      [ nil, rgb, nil, nil, nil ],
      [ nil, nil, nil, rgb, nil ],
      [ nil, nil, rgb, nil, nil ],
    ]

    img = build_image_from_pixel_map pixel_map
    img = img.rotate( -90 ) if @axis == :y
    img = img.invert( @axis ) if invert?

    size = img.size( @axis )

    size.times do |i|
       detector = Chunking::Detector.new( :axis => @axis, :tolerance => i, :size => size, :rgb => rgb )
       assert_equal i+1, detector.detect_boundary( img, 0, invert? ).index
    end
  end

  def test_invert
  end

  def test_fuzz
  end

  def test_no_matches
  end

  def test_all_matches
  end
end
