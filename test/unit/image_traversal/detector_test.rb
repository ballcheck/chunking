require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectorTest < TestCase

    #---------------
    # initialisation
    #---------------

    def test_method_initialize_should_set_values
      # all args.
      axis, offset, size, colour, fuzz, density, tolerance = [
        stub( "axis" ), stub( "offset" ), stub( "size" ), stub( "colour" ),
        stub( "fuzz" ), stub( "density" ), stub( "tolerance" )
      ]

      # create detector with args.
      d = Detector.new( axis, offset, size, colour, fuzz, density, tolerance )

      # then...
      assert_equal(
        [ axis, offset, size, colour, fuzz, density, tolerance, [] ],
        [ d.axis, d.offset, d.size, d.colour, d.fuzz, d.density, d.tolerance, d.runs ]
      )
    end

    def test_method_factory_should_set_values
      # all args.
      axis, offset, size, colour, fuzz, density, tolerance = [
        stub( "axis" ), stub( "offset" ), stub( "size" ), stub( "colour" ),
        stub( "fuzz" ), stub( "density" ), stub( "tolerance" )
      ]

      # create detector with args using the factory.
      d = build_detector( nil, {
        :axis => axis, :offset => offset, :size => size, :colour => colour,
        :fuzz => fuzz, :density => density, :tolerance => tolerance
      } )

      # then...
      assert_equal(
        [ axis, offset, size, colour, fuzz, density, tolerance ],
        [ d.axis, d.offset, d.size, d.colour, d.fuzz, d.density, d.tolerance ]
      )
    end

    def test_method_factory_should_set_defaults
      # create detector with default values using factory
      d = Detector.factory

      # then...
      assert_equal(
        [ :x, 0, Rational( 1 ), Palette.black, 0, 1, 0 ],
        [ d.axis, d.offset, d.size, d.colour, d.fuzz, d.density, d.tolerance ]
      )
    end

    #--------
    # methods
    #--------

    # TODO: see detect_boundary_test.rb & detect_colour_test.rb
    def test_method_detect_nth_boundary
      d = build_detector
      n = 3

      # dummy values to be passed in.
      img, start_index, invert_direction = stub, stub, stub

      # dummy boundaries.
      b1 = Boundary.new( nil, stub )
      b2 = Boundary.new( nil, stub )
      b3 = Boundary.new( nil, stub )

      # rig so each boundary's index gets passed to the next call.
      d.stubs( :detect_boundary ).with( img, start_index, invert_direction ).returns( b1 )
      d.stubs( :detect_boundary ).with( img, b1.index, invert_direction ).returns( b2 )
      d.stubs( :detect_boundary ).with( img, b2.index, invert_direction ).returns( b3 )

      # then...
      # the nth boundary is returned
      assert_equal b3, d.detect_nth_boundary( img, n, start_index, invert_direction )

      # but we get nil if no boundary is returned.
      d.stubs( :detect_boundary ).with( img, b2.index, invert_direction ).returns( nil )
      assert_equal nil, d.detect_nth_boundary( img, n, start_index, invert_direction )
    end

    def test_method_detect_colour_should_add_pixels_to_result
      # img with random dimensions
      img_height = img_width = (2..99).to_a.sample
      img = ImageTraversal.image_adapter_class.factory( img_width, img_height )

      # detector with random params.
      line_index = (0..img_height-1).to_a.sample
      offset = (0..img_width-1).to_a.sample
      size = (1..img_width-offset).to_a.sample
      detector = build_detector( nil, :size => size, :offset => offset )

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
      coords_x_axis = build_detector( nil, :axis => :x ).send( :determine_pixel_coords, *args )
      assert_equal [ index + offset, line_index ], coords_x_axis

      coords_y_axis = build_detector( nil, :axis => :y ).send( :determine_pixel_coords, *args )
      assert_equal [ line_index, image_size - 1 - ( index + offset ) ], coords_y_axis
    end

    def test_method_determine_last_line_index
      # create image of random size
      width, height = (1..99).to_a.sample( 2 )
      img = ImageTraversal.image_adapter_class.factory( width, height )

      # then...
      assert_equal width - 1, build_detector( nil, :axis => :y ).send( :determine_last_line_index, img )
      assert_equal height - 1, build_detector( nil, :axis => :x ).send( :determine_last_line_index, img )
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
      detector = build_detector( nil, :density => density )

      # then...
      assert !detector.send( :density_reached?, density - 1 )
      assert detector.send( :density_reached?, density )
      assert detector.send( :density_reached?, density + 1 )
    end
  end
end
