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

      def image_from_pixel_map( pixel_map )
        img = ImageTraversal.image_adapter_class.from_pixel_map( pixel_map )
        img = img.rotate( -90 ) if @axis == :y
        img = img.invert( @axis ) if invert?
        return img
      end

      def detector_args( args_to_merge )
        { :fuzz => @fuzz, :axis => @axis, :colour => @colour }.merge( args_to_merge )
      end
    end

    # Tests that work the same way when background / foreground colours are inverted.
    module ColourFastTests
      include Setup
      def test_start_index
        _, x = @background_colour, @foreground_colour
        img = image_from_pixel_map([
          [ _, _, _, _, _ ],
          [ x, x, x, x, x ],
          [ _, _, _, _, _ ],
          [ _, _, _, _, _ ],
          [ x, x, x, x, x ],
          [ _, _, _, _, _ ]
        ])

        size = img.size( @axis )
        detector = build_detector( detector_args( :size => size ) )

        # then...
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
        img = image_from_pixel_map([
          [ _, _, _, _, _ ],
          [ x, x, x, x, x ],
          [ _, _, _, _, _ ],
          [ _, _, _, _, _ ],
        ])

        size = img.size( @axis )
        detector = build_detector( detector_args( :size => size ) )

        # then...
        # boundary is from the top of the image.
        assert_equal 1, detector.detect_boundary( img, 0, invert? ).index
       
        # also...
        # boundary is from the bottom of the image.
        assert_equal 2, detector.detect_boundary( img, 0, !invert? ).index
      end

      def test_no_matches
        _, x = @background_colour, @foreground_colour
        img = image_from_pixel_map([
          [ _, _, _, _, _ ],
          [ _, _, _, _, _ ],
          [ _, _, _, _, _ ],
        ])

        size = img.size( @axis )
        detector = build_detector( detector_args( :size => size ) )

        # then...
        # no boundary is returned
        assert_equal nil, detector.detect_boundary( img, 0, invert? )
      end

      # def test_all_matches
      # # this is covered by inverting bg/fg colours
      # end
      
      def test_tolerance
        _, x = @background_colour, @foreground_colour
        img = image_from_pixel_map([
          [ _, _, _ ],
          [ x, x, x ],
          [ _, _, _ ],
          [ x, x, x ],
          [ x, x, x ],
        ])

        size = img.size( @axis )

        # expected boundaries at different tolerance levels.
        tolerance_index_map = {
          0 => 1,
          1 => 3,
          2 => nil
        }

        # then...
        tolerance_index_map.each do |key,val|
          detector = build_detector( detector_args( :size => size, :tolerance => key ) )
          boundary = detector.detect_boundary( img, 0, invert? )
          index = boundary ? boundary.index : nil
          assert_equal val, index
        end
      end
    end
    
    # Tests that don't make sense if background / foreground colours are inverted relative to @colour.
    module NonColourFastTests
      include Setup
      def test_offset
        _, x = @background_colour, @foreground_colour
        img = image_from_pixel_map([
          [ _, _, _, _, _ ],
          [ x, _, _, _, _ ],
          [ x, x, _, _, _ ],
          [ x, x, x, _, _ ],
          [ x, x, x, x, _ ],
          [ x, x, x, x, x ]
        ])

        size = img.size( @axis )

        # then...
        size.times do |i|
          # offset increasing by 1 each time
          detector = build_detector( detector_args( :size => size-i, :offset => i ) )
          assert_equal i+1,  detector.detect_boundary( img, 0, invert? ).index
        end
      end

      def test_size
        _, x = @background_colour, @foreground_colour
        img = image_from_pixel_map([
          [ _, _, _, _, _ ],
          [ _, _, _, _, x ],
          [ _, _, _, x, x ],
          [ _, _, x, x, x ],
          [ _, x, x, x, x ],
          [ x, x, x, x, x ]
        ])

        size = img.size( @axis )

        # then...
        size.times do |i|
          # size decreasing by 1 each time
          detector = build_detector( detector_args( :size => size - i ) )
          assert_equal i+1, detector.detect_boundary( img, 0, invert? ).index
        end
      end

      def test_density
        _, x = @background_colour, @foreground_colour
        img = image_from_pixel_map([
          [ _, _, _, _, _ ],
          [ _, _, x, _, _ ],
          [ _, x, x, _, _ ],
          [ _, x, x, x, _ ],
          [ x, x, x, x, _ ],
          [ x, x, x, x, x ]
        ])

        size = img.size( @axis )

        # then...
        size.times do |i|
          # density increasing by 1 each time
          detector = build_detector( detector_args( :size => size, :density => i + 1 ) )
          assert_equal i+1, detector.detect_boundary( img, 0, invert? ).index
        end
      end

      # TODO: this wants some comments.
      def test_annotation
        _, x = @background_colour, @foreground_colour

        img = image_from_pixel_map([
          [ _, _, _, _, _ ],
          [ _, _, x, _, _ ],
          [ _, x, x, _, _ ]
        ])

        size = img.size( @axis ) - 2

        detector = build_detector( detector_args( :size => size, :density => 2, :offset => 1 ) )
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
