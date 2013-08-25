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

  class XAxisSwapFGBG < ActiveSupport::TestCase
    include ColourFastTests

    # Swap background / foreground colours so we start on a colour, and move off. 
    # Only works on ColourFastTests.
    def setup
      super
      @background_rgb = @rgb
      @foreground_rgb = ::Chunking::Image::RMagickImage::WHITE_RGB
    end
  end
end
