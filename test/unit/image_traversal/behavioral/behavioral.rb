require File.expand_path( "../../test_helper.rb", __FILE__ )
# TODO: this should be a gem or lib file
require "./../array/array.rb"
module ImageTraversal

  # A suite of behavioural tests that can be repeated under varying conditions.
  module Behavioral
    # These methods are overridden in test_cases.rb
    module Setup
      # Set up for the test.
      def setup
        @axis = :x
        @colour = Palette.black
        @foreground_colour = @colour
        @background_colour = Palette.white
        @fuzz = 0
      end

      # Whether the image should be inverted for this test or not.
      def invert?
        false
      end

    end

    # Tests that work the same way when background / foreground colours are inverted.
    module ColourFastTests
      include Setup
      def test_start_index
        _, x = @background_colour, @foreground_colour
        pixel_map = [
          [ _, _, _, _, _ ],
          [ x, x, x, x, x ],
          [ _, _, _, _, _ ],
          [ _, _, _, _, _ ],
          [ x, x, x, x, x ],
          [ _, _, _, _, _ ]
        ]

        img = ImageTraversal.image_adapter_class.from_pixel_map( pixel_map )

        img = img.rotate( -90 ) if @axis == :y
        img = img.invert( @axis ) if invert?

        detector = build_detector( :fuzz => @fuzz, :axis => @axis, :size => 5, :colour => @colour )

        # immediate boundary
        assert_equal 1, detector.detect_boundary( img, 0, invert? ).index
        # jump a row to boundary
        assert_equal 4, detector.detect_boundary( img, 2, invert? ).index
        # same boundary different start
        assert_equal 4, detector.detect_boundary( img, 3, invert? ).index
        # last row
        assert_equal nil, detector.detect_boundary( img, 5, invert? )
      end

      def test_invert
        _, x = @background_colour, @foreground_colour
        pixel_map = [
          [ _, _, _, _, _ ],
          [ x, x, x, x, x ],
          [ _, _, _, _, _ ],
          [ _, _, _, _, _ ],
        ]

        img = ImageTraversal.image_adapter_class.from_pixel_map( pixel_map )
        img = img.rotate( -90 ) if @axis == :y
        img = img.invert( @axis ) if invert?

        size = img.size( @axis )

        detector = Detector.factory( :fuzz => @fuzz, :axis => @axis, :size => size, :colour => @colour )
        assert_equal 1, detector.detect_boundary( img, 0, invert? ).index
       
        detector = Detector.factory( :fuzz => @fuzz, :axis => @axis, :size => size, :colour => @colour )
        assert_equal 2, detector.detect_boundary( img, 0, !invert? ).index
      end

      def test_fuzz
      end

      def test_no_matches
        _, x = @background_colour, @foreground_colour
        pixel_map = [
          [ _, _, _, _, _ ],
          [ _, _, _, _, _ ],
          [ _, _, _, _, _ ],
        ]

        img = ImageTraversal.image_adapter_class.from_pixel_map( pixel_map )
        img = img.rotate( -90 ) if @axis == :y
        img = img.invert( @axis ) if invert?
        size = img.size( @axis )

        detector = Detector.factory( :fuzz => @fuzz, :axis => @axis, :size => size, :colour => @colour )
        assert_equal nil, detector.detect_boundary( img, 0, invert? )
      end

      # def test_all_matches
      # # this is covered by inverting bg/fg colours
      # end
      
      def test_tolerance
        _, x = @background_colour, @foreground_colour
        pixel_map = [
          [ _, _, _ ],
          [ x, x, x ],
          [ _, _, _ ],
          [ x, x, x ],
          [ x, x, x ],
          [ _, _, _ ],
          [ x, x, x ],
          [ x, x, x ],
          [ x, x, x ],
        ]

        img = ImageTraversal.image_adapter_class.from_pixel_map( pixel_map )
        img = img.rotate( -90 ) if @axis == :y
        img = img.invert( @axis ) if invert?

        size = img.size( @axis )

        tolerance_index_map = {
          0 => 1,
          1 => 3,
          2 => 6,
          3 => nil
        }

        tolerance_index_map.each do |k,v|
          detector = Detector.factory( :fuzz => @fuzz, :axis => @axis, :tolerance => k, :size => size, :colour => @colour )
          boundary = detector.detect_boundary( img, 0, invert? )
          index = boundary ? boundary.index : nil
          assert_equal v, index
        end
      end
    end
    
    # Tests that don't make sense if background / foreground colours are inverted relative to @colour.
    module NonColourFastTests
      include Setup
      def test_offset
        _, x = @background_colour, @foreground_colour
        pixel_map = [
          [ _, _, _, _, _ ],
          [ x, _, _, _, _ ],
          [ x, x, _, _, _ ],
          [ x, x, x, _, _ ],
          [ x, x, x, x, _ ],
          [ x, x, x, x, x ]
        ]

        img = ImageTraversal.image_adapter_class.from_pixel_map( pixel_map )
        img = img.rotate( -90 ) if @axis == :y
        img = img.invert( @axis ) if invert?

        size = img.size( @axis )

        size.times do |i|
           detector = Detector.factory( :fuzz => @fuzz, :axis => @axis, :offset => i, :size => size - i, :colour => @colour )
           assert_equal i+1,  detector.detect_boundary( img, 0, invert? ).index
        end
      end

      def test_size
        _, x = @background_colour, @foreground_colour
        pixel_map = [
          [ _, _, _, _, _ ],
          [ _, _, _, _, x ],
          [ _, _, _, x, x ],
          [ _, _, x, x, x ],
          [ _, x, x, x, x ],
          [ x, x, x, x, x ]
        ]

        img = ImageTraversal.image_adapter_class.from_pixel_map( pixel_map )
        img = img.rotate( -90 ) if @axis == :y
        img = img.invert( @axis ) if invert?

        size = img.size( @axis )

        size.times do |i|
           detector = Detector.factory( :fuzz => @fuzz, :axis => @axis, :size => size - i, :colour => @colour )
           assert_equal i+1, detector.detect_boundary( img, 0, invert? ).index
        end
      end

      def test_density
        _, x = @background_colour, @foreground_colour
        pixel_map = [
          [ _, _, _, _, _ ],
          [ _, _, x, _, _ ],
          [ _, x, x, _, _ ],
          [ _, x, x, x, _ ],
          [ x, x, x, x, _ ],
          [ x, x, x, x, x ]
        ]

        img = ImageTraversal.image_adapter_class.from_pixel_map( pixel_map )
        img = img.rotate( -90 ) if @axis == :y
        img = img.invert( @axis ) if invert?

        size = img.size( @axis )

        5.times do |i|
           detector = Detector.factory( :fuzz => @fuzz, :axis => @axis, :density => i + 1, :size => size, :colour => @colour )
           assert_equal i+1, detector.detect_boundary( img, 0, invert? ).index
        end
      end

      def test_annotation
        _, x = @background_colour, @foreground_colour

        pixel_map = [
          [ _, _, _, _, _ ],
          [ _, _, x, _, _ ],
          [ _, x, x, _, _ ]
        ]

        img = ImageTraversal.image_adapter_class.from_pixel_map( pixel_map )
        img = img.rotate( -90 ) if @axis == :y
        img = img.invert( @axis ) if invert?

        size = img.size( @axis ) - 2

        detector = Detector.factory( :fuzz => @fuzz, :axis => @axis, :density => 2, :size => size, :colour => @colour, :offset => 1 )
        assert_equal 2, detector.detect_boundary( img, 0, invert? ).index
        annotated_img = detector.runs.last.annotate( img, 1 )

        a = Palette.annotate_nil
        b = Palette.annotate_pixel_is_colour
        c = Palette.annotate_density_reached

        annotation_colour_map = [ 
          [ _, a, a, a, _ ],
          [ _, a, b, a, _ ],
          [ _, b, c, _, _ ]
        ]

        annotation_colour_map = annotation_colour_map.rotate( true ) if @axis == :y
        annotation_colour_map = annotation_colour_map.invert( @axis ) if invert?

        annotation_colour_map.each_with_index do |row, row_ind|
          row.each_with_index do |col, col_ind|
            pixel_colour = annotated_img.get_pixel_colour( col_ind, row_ind )
            assert_equal col, pixel_colour, "row_ind: #{row_ind}, col_ind: #{col_ind}"
          end
        end
      end

    end

    # Container for ColourFastTests and NonColourFastTests
    module AllTests
      include ColourFastTests
      include NonColourFastTests
    end
  end
end
