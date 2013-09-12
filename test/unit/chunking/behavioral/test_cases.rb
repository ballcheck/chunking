module Chunking

  require File.expand_path( "../behavioral.rb", __FILE__ )
  module Behavioral
    class XAxis < TestCase
      include AllTests
    end

    class YAxis < TestCase
      include AllTests

      def setup
        super
        @axis = :y
      end
    end

    class XAxisInvert < TestCase
      include AllTests

      def invert?
        true
      end
    end

    class YAxisInvert < TestCase
      include AllTests

      def setup
        super
        @axis = :y
      end

      def invert?
        true
      end
    end

    class XAxisArrayOfColours < TestCase
      include AllTests

      def setup
        super
        @colour = [
          [ 0, 0, 0, 0 ],
          [ 1000, 1000, 1000, 0 ],
          [ 10000, 10000, 10000, 0 ]
        ]

        @foreground_colour = @colour[ 1 ]
      end
    end

    class XAxisFuzz < TestCase
      include AllTests

      def setup
        super
        @colour = [ 0, 0, 0, 0 ]
        @foreground_colour = [ 1000, 1000, 1000, 0 ]
        @fuzz = 1000
      end
    end

    class XAxisSwapFGBG < TestCase
      include ColourFastTests

      # Swap background / foreground colours so we start on a colour, and move off. 
      # Only works on ColourFastTests.
      def setup
        super
        @background_colour = @colour
        @foreground_colour = Image::RMagick::WHITE_RGB
      end
    end

    class YAxisSwapFGBG < TestCase
      include ColourFastTests

      # Swap background / foreground colours so we start on a colour, and move off. 
      # Only works on ColourFastTests.
      def setup
        super
        @background_colour = @colour
        @foreground_colour = Image::RMagick::WHITE_RGB
        @axis = :y
      end
    end

    class Other < TestCase
      def test_should_work_with_image_path
        ::Dir.mktmpdir do |d|
          file_path = File.join( d, "image.jpg" )
          Magick::Image.new( 10, 10 ).write( file_path )
          detector = Detector.new
          detector.detect_boundary( file_path )
          assert_equal detector.runs.last.image.base_image, Magick::Image.read( file_path ).first
        end
      end
    end

  end
end
