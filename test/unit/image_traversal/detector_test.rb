require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectorTest < TestCase

    #---------------
    # initialisation
    #---------------

    def test_method_factory_should_set_values
      # all args.
      axis, offset, size, colour, fuzz, density, tolerance, do_add_pixels = stub, stub, stub, stub, stub, stub, stub

      # create detector with args using the factory.
      d = Detector.default( {
        :axis => axis, :offset => offset, :size => size, :colour => colour,
        :fuzz => fuzz, :density => density, :tolerance => tolerance, :do_add_pixels => do_add_pixels
      } )

      # then...
      assert_equal(
        [ axis, offset, size, colour, fuzz, density, tolerance, do_add_pixels ],
        [ d.axis, d.offset, d.size, d.colour, d.fuzz, d.density, d.tolerance, d.do_add_pixels ]
      )
    end

    def test_method_factory_should_set_defaults
      # create detector with default values using factory
      d = Detector.default

      # then...
      assert_equal(
        [ :x, 0, Rational( 1 ), Palette.black, 0, 1, 0 ],
        [ d.axis, d.offset, d.size, d.colour, d.fuzz, d.density, d.tolerance ]
      )
    end

    #--------
    # methods
    #--------

    def test_method_detect_colour_should_add_pixels_to_result
      # img with random dimensions
      img_height = img_width = (2..99).to_a.sample
      img = ImageTraversal.image_adapter_class.factory( img_width, img_height )

      # detector with random params.
      line_index = (0..img_height-1).to_a.sample
      offset = (0..img_width-1).to_a.sample
      size = (1..img_width-offset).to_a.sample
      detector = build_detector( :size => size, :offset => offset, :do_add_pixels => true )

      # make detector run to the end
      detector.stubs( :density_reached? ).returns( false )

      # colour_states to expect later.
      colour_states = (0..size).to_a.map{ |x| [true, false].sample }
      img.stubs( :pixel_is_colour? ).returns( *colour_states )

      # then...
      result = detector.detect_colour?( img, line_index )

      assert result.pixels.count == size
      size.times do |i|
        pixel = result.pixels[i]
        assert_equal line_index, pixel.y
        assert_equal offset+i, pixel.x
        assert_equal colour_states[i], pixel.colour_state
      end
    end

    # ---------------
    # private methods
    # ---------------

    def test_method_determine_pixel_coords
      # args with random values.
      offset, index, line_index, image_size = (1..99).to_a.sample( 4 )
      args = [ offset, index, line_index, image_size ]

      # then...
      coords_x_axis = build_detector( :axis => :x ).send( :determine_pixel_coords, *args )
      assert_equal [ index + offset, line_index ], coords_x_axis

      coords_y_axis = build_detector( :axis => :y ).send( :determine_pixel_coords, *args )
      assert_equal [ line_index, image_size - 1 - ( index + offset ) ], coords_y_axis
    end

    def test_method_determine_last_line_index
      # create image of random size
      width, height = (1..99).to_a.sample( 2 )
      img = ImageTraversal.image_adapter_class.factory( width, height )

      # then...
      assert_equal width - 1, build_detector( :axis => :y ).send( :determine_last_line_index, img )
      assert_equal height - 1, build_detector( :axis => :x ).send( :determine_last_line_index, img )
    end

    def test_method_determine_absolute_line_index
      d = build_detector

      # args with random values.
      last_line_index, line_index = (0..99).to_a.sample( 2 )
   
      # then...
      # if not inverting direction, just use line index.
      assert_equal line_index, d.send( :determine_absolute_line_index, false, last_line_index, line_index )

      # if inverting, factor in image size.
      assert_equal ( last_line_index - line_index ), d.send( :determine_absolute_line_index, true, last_line_index, line_index )
    end

    def test_method_density_reached?
      # detector with random density
      density = (1..99).to_a.sample
      d = build_detector( :density => density )

      # then...
      assert !d.send( :density_reached?, density - 1 )
      assert d.send( :density_reached?, density )
      assert d.send( :density_reached?, density + 1 )
    end

    def test_method_determine_boundary
      d = build_detector
      run = build_run

      # args with random values.
      line_index = (0..99).to_a.sample
      run_tolerance_counter = (0..99).to_a.sample

      # frig run.tolerance_counter
      run.stubs( :tolerance_counter ).returns( run_tolerance_counter )

      # then...
      d.stubs( :tolerance_exceeded? ).with( run_tolerance_counter ).returns( true )
      boundary = d.send( :determine_boundary, line_index, run )
      assert_equal d.axis, boundary.axis
      assert_equal ( line_index - run.tolerance_counter + 1 ), boundary.index

      # also...
      d.stubs( :tolerance_exceeded? ).with( run_tolerance_counter ).returns( false )
      assert_equal nil, d.send( :determine_boundary, line_index, run )
    end

    def test_method_retrieve_image
      d = build_detector

      # image of the class ImageTraversal.image_adapter_class
      img = build_image

      # any other image value
      non_img = stub
      new_img = stub
      ImageTraversal.image_adapter_class.stubs( :factory ).with( non_img ).returns( new_img )

      # then...
      # an img of image_adapter_class comes back untouched
      assert_equal img, d.send( :retrieve_image, img )

      # but anything else goes to the factory
      assert_equal new_img, d.send( :retrieve_image, non_img )
    end

    def test_method_tolerance_exceeded
      # detector with random tolerance
      tolerance = (0..99).to_a.sample
      d = build_detector( :tolerance => tolerance )

      # then...
      assert_equal false, d.send( :tolerance_exceeded?, tolerance-1 )
      assert_equal false, d.send( :tolerance_exceeded?, tolerance )
      assert_equal true, d.send( :tolerance_exceeded?, tolerance+1 )
    end

    def test_method_determine_offset_rational
      # Given
      # an image of random size
      axis = stub
      image_size = (1..99).to_a.sample
      image = build_image_with_stubbed_size( axis, image_size )

      # a Detector with random offset
      offset = given_a_random_rational
      d = build_detector( :axis => axis, :offset => offset )

      # When
      offset_result = d.send( :determine_offset, image )

      # Then
      # relative to image size if it's a Rational
      assert_equal ( image_size * offset.to_f ).to_i, offset_result
    end

    def test_method_determine_offset_int
      # Given
      # an image of random size
      axis = stub
      image_size = (1..99).to_a.sample
      image = build_image_with_stubbed_size( axis, image_size )

      # a Detector with random offset
      offset = (0..99).to_a.sample
      d = build_detector( :axis => axis, :offset => offset )

      # When
      offset_result = d.send( :determine_offset, image )

      # Then
      # get the original back if it's an int.
      assert_equal offset, offset_result
    end
      
    def test_method_determine_size_rational
      # Given
      # an image of random size
      axis = stub
      image_size = (1..99).to_a.sample
      image = build_image_with_stubbed_size( axis, image_size )

      # a Detector of random size
      size = given_a_random_rational
      d = build_detector( :axis => axis, :size => size )

      # When
      size_result = d.send( :determine_size, image )

      # Then
      # relative to image size if it's a Rational
      assert_equal ( image_size * size.to_f ).to_i, size_result
    end

    def test_method_determine_size_int
      # Given
      # an image of random size
      axis = stub
      image_size = (1..99).to_a.sample
      image = build_image_with_stubbed_size( axis, image_size )

      # a Detector of random size
      size = (0..99).to_a.sample
      d = build_detector( :axis => axis, :size => size )

      # When
      size_result = d.send( :determine_size, image )

      # Then
      # get the original back if it's an int.
      size_result = d.send( :determine_size, image )
      assert_equal size, size_result
    end

    def test_method_determine_density_with_rational
      # Given
      # an image of random size
      axis = stub
      image_size = (1..99).to_a.sample
      image = build_image_with_stubbed_size( axis, image_size )

      # a detector of random density
      density = given_a_random_rational
      d = build_detector( :axis => axis, :density => density )

      # When
      density_result = d.send( :determine_density, image )

      # Then
      # relative to image size if it's a Rational
      assert_equal ( image_size * density.to_f ).to_i, density_result
    end

    def test_method_determine_density_with_integer
      # Given
      # an image of random size
      axis = stub
      image_size = (1..99).to_a.sample
      image = build_image_with_stubbed_size( axis, image_size )

      # a detector of random density
      density = (0..99).to_a.sample
      d = build_detector( :axis => axis, :density => density )

      # When
      density_result = build_detector( :density => density ).send( :determine_density, image )

      # Then
      # get the original back if it's an int.
      assert_equal density, density_result
    end

  end
end
