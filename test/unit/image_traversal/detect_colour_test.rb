require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectColourTest < TestCase
    
    def test_should_detect_colour_if_pixel_is_colour
      img = mock( "img" )
      img.expects( :pixel_is_colour? ).once.returns( true )
      detector = build_detector( img )
      assert detector.detect_colour?( img )
    end

    def test_should_not_detect_colour_if_pixel_is_not_colour
      img = mock( "img" )
      img.expects( :pixel_is_colour? ).returns( false )
      detector = build_detector( img )
      assert !detector.detect_colour?( img ).colour_detected?
    end

    #def test_should_annotate_correctly
    #  img = stub_everything( "img" )
    #  detector = build_detector( img )
    #  with_vals = [ [ 0, 0, nil ], [ 0, 0, :pixel_is_colour ], [ 0, 0, :density_reached ] ]
    #  with_pos = 0
    #  detector.expects( :annotate_image ).times( 3 ).with{ |*a| a == with_vals[with_pos]; with_pos +=1 }
    #  #seq = sequence( "seq" )
    #  #detector.expects( :annotate_image ).once.with( 0, 0, nil ).in_sequence( seq )
    #  #detector.expects( :annotate_image ).once.with( 0, 0, :pixel_is_colour ).in_sequence( seq )
    #  #detector.expects( :annotate_image ).once.with( 0, 0, :density_reached ).in_sequence( seq )
    #  detector.expects( :density_reached? ).times( 2 ).returns( false, true )
    #  img.expects( :pixel_is_colour? ).times( 3 ).returns( false, true, true )
    #  assert !detector.detect_colour?( img, nil, true )
    #  assert !detector.detect_colour?( img, nil, true )
    #  assert detector.detect_colour?( img, nil, true )
    #end

    def test_should_check_all_pixels
      size = 3
      img = mock( "img" )
      img.expects( :pixel_is_colour? ).once.with{ |*args| args[0] == 0 }
      img.expects( :pixel_is_colour? ).once.with{ |*args| args[0] == 1 }
      img.expects( :pixel_is_colour? ).once.with{ |*args| args[0] == 2 }
      detector = build_detector( img, :size => size )
      detector.detect_colour?( img )
    end

    def test_should_stop_checking_when_detected
      size = 5
      img = mock( "img" )
      img.expects( :pixel_is_colour? ).times( 1 ).returns( true )
      detector = build_detector( img, :size => size )
      assert detector.detect_colour?( img )
    end

    def test_should_not_return_nil_if_colour_not_detected
      img = mock( "img" )
      img.expects( :pixel_is_colour? ).returns( false )
      detector = build_detector( img )
      assert !detector.detect_colour?( img ).nil?
    end

    def test_should_detect_colour_if_density_reached
      img = mock( "img" )
      img.stubs( :pixel_is_colour? ).returns( true )
      detector = build_detector( img )
      detector.expects( :density_reached? ).with( 1, img ).returns( true )
      assert detector.detect_colour?( img )
    end

    def test_should_not_detect_colour_if_density_not_reached
      img = mock( "img" )
      img.stubs( :pixel_is_colour? ).returns( true )
      detector = build_detector( img )
      detector.expects( :density_reached? ).with( 1, img ).returns( false )
      assert !detector.detect_colour?( img ).colour_detected?
    end

    def test_should_correctly_observe_offset_and_size_on_x_axis
      img = mock( "img" )
      size = 4
      offset = 3
      line_index = 2
      detector = build_detector( img, :size => size, :offset => offset, :axis => :x )

      img.expects( :pixel_is_colour? ).once.with { |*args| args[0] == offset && args[1] == line_index }
      img.expects( :pixel_is_colour? ).once.with { |*args| args[0] == offset + 1 && args[1] == line_index }
      img.expects( :pixel_is_colour? ).once.with { |*args| args[0] == offset + 2 && args[1] == line_index }
      img.expects( :pixel_is_colour? ).once.with { |*args| args[0] == offset + 3 && args[1] == line_index }
      detector.detect_colour?( img, line_index )
    end

    def test_should_correctly_observe_offset_and_size_on_y_axis
      img = mock( "img" )
      size = 4
      offset = 3
      line_index = 2
      detector = build_detector( img, :size => size, :offset => offset, :axis => :y )
      img_size = 10
      img.stubs( :size ).returns( img_size )
      real_offset = img_size - 1 - offset

      img.expects( :pixel_is_colour? ).once.with { |*args| args[1] == real_offset && args[0] == line_index }
      img.expects( :pixel_is_colour? ).once.with { |*args| args[1] == real_offset - 1 && args[0] == line_index }
      img.expects( :pixel_is_colour? ).once.with { |*args| args[1] == real_offset - 2 && args[0] == line_index }
      img.expects( :pixel_is_colour? ).once.with { |*args| args[1] == real_offset - 3 && args[0] == line_index }
      detector.detect_colour?( img, line_index )
    end

  end
end
