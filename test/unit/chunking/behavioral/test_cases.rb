module Chunking

  # TODO: surely you don't have to require the other files in the module...
  require File.expand_path( "../behavioral.rb", __FILE__ )
  module Behavioral
    class XAxis < ActiveSupport::TestCase
      include AllTests
    end

    class YAxis < ActiveSupport::TestCase
      include AllTests

      def setup
        super
        @axis = :y
      end
    end

    class XAxisInvert < ActiveSupport::TestCase
      include AllTests

      def invert?
        true
      end
    end

    class YAxisInvert < ActiveSupport::TestCase
      include AllTests

      def setup
        super
        @axis = :y
      end

      def invert?
        true
      end
    end

    class XAxisArrayOfColours < ActiveSupport::TestCase
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

    class XAxisFuzz < ActiveSupport::TestCase
      include AllTests

      def setup
        super
        @colour = [ 0, 0, 0, 0 ]
        @foreground_colour = [ 1000, 1000, 1000, 0 ]
        @fuzz = 1000
      end
    end

    class XAxisSwapFGBG < ActiveSupport::TestCase
      include ColourFastTests

      # Swap background / foreground colours so we start on a colour, and move off. 
      # Only works on ColourFastTests.
      def setup
        super
        @background_colour = @colour
        @foreground_colour = Image::RMagick::WHITE_RGB
      end
    end

    class YAxisSwapFGBG < ActiveSupport::TestCase
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

  end
end
