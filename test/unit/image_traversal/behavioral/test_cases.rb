module ImageTraversal

  require File.expand_path( "../behavioral.rb", __FILE__ )
  module Behavioral
    class BenchmarkTests < TestCase
      def xtest_image_size
        Benchmark.bm { |bm|
          n = 1000000
          magick_image1 = Magick::Image.new( 500, 500 )
          adapter_image1 = Image::AdapterMagickImage.factory( magick_image1 )
          
          bm.report( "rows" ){
            n.times do
              magick_image1.rows
            end
          }

          bm.report( "size( :x )" ){
            n.times do
              adapter_image1.size( :x )
            end
          }

          bm.report( "pixel_color" ){
            n.times do
              magick_image1.pixel_color( 1, 1 )
            end
          }

          bm.report( "get_pixel_colour" ){
            n.times do
              adapter_image1.get_pixel_colour( 1, 1 )
            end
          }

        }
      end

    end

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
        @foreground_colour = Palette.white
      end
    end

    class YAxisSwapFGBG < TestCase
      include ColourFastTests

      # Swap background / foreground colours so we start on a colour, and move off. 
      # Only works on ColourFastTests.
      def setup
        super
        @background_colour = @colour
        @foreground_colour = Palette.white
        @axis = :y
      end
    end

  end
end
