require "test/unit"
require File.expand_path( "../test_helper", __FILE__ )

class CTR
  class << self
    def run
      # console test runner
      Dir.glob(Rails.root.to_s + '/test/unit/*', &method( :load ) )
      # TODO: this is not including subdirs i.e. image
      Dir.glob(Rails.root.to_s + '/lib/chunking/*.rb', &method( :load ) )
      Test::Unit::AutoRunner.run
      #DetectColourTest.new("").test_should_detect_colour_if_pixel_is_colour
    end
  end


end
