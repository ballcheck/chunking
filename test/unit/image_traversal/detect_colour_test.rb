require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectColourTest < TestCase
    
    def test_should_detect_colour_if_pixel_is_colour
      img = build_image
      img.expects( :pixel_is_colour? ).once.returns( true )
      detector = build_detector
      assert detector.detect_colour?( img )
    end

    def test_should_not_detect_colour_if_pixel_is_not_colour
      img = build_image
      img.expects( :pixel_is_colour? ).returns( false )
      detector = build_detector
      assert !detector.detect_colour?( img ).colour_detected?
    end

    def test_should_check_all_pixels
      size = 3
      img = build_image
      img.expects( :pixel_is_colour? ).once.with{ |*args| args[0] == 0 }
      img.expects( :pixel_is_colour? ).once.with{ |*args| args[0] == 1 }
      img.expects( :pixel_is_colour? ).once.with{ |*args| args[0] == 2 }
      detector = build_detector( :size => size )
      detector.detect_colour?( img )
    end

    def test_should_stop_checking_when_detected
      size = 5
      img = build_image
      img.expects( :pixel_is_colour? ).times( 1 ).returns( true )
      detector = build_detector( :size => size )
      assert detector.detect_colour?( img )
    end

    def test_should_not_return_nil_if_colour_not_detected
      img = build_image
      img.expects( :pixel_is_colour? ).returns( false )
      detector = build_detector
      assert !detector.detect_colour?( img ).nil?
    end

    def test_should_detect_colour_if_density_reached
      img = build_image
      img.stubs( :pixel_is_colour? ).returns( true )
      detector = build_detector
      detector.expects( :density_reached? ).with( 1, img ).returns( true )
      assert detector.detect_colour?( img )
    end

    def test_should_not_detect_colour_if_density_not_reached
      img = build_image
      img.stubs( :pixel_is_colour? ).returns( true )
      detector = build_detector
      detector.expects( :density_reached? ).with( 1, img ).returns( false )
      assert !detector.detect_colour?( img ).colour_detected?
    end

    def test_should_correctly_observe_offset_and_size_on_x_axis
      img = build_image
      size = 4
      offset = 3
      line_index = 2
      detector = build_detector( :size => size, :offset => offset, :axis => :x )

      img.expects( :pixel_is_colour? ).once.with { |*args| args[0] == offset && args[1] == line_index }
      img.expects( :pixel_is_colour? ).once.with { |*args| args[0] == offset + 1 && args[1] == line_index }
      img.expects( :pixel_is_colour? ).once.with { |*args| args[0] == offset + 2 && args[1] == line_index }
      img.expects( :pixel_is_colour? ).once.with { |*args| args[0] == offset + 3 && args[1] == line_index }
      detector.detect_colour?( img, line_index )
    end

    def test_should_correctly_observe_offset_and_size_on_y_axis
      img = build_image
      size = 4
      offset = 3
      line_index = 2
      detector = build_detector( :size => size, :offset => offset, :axis => :y )
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
