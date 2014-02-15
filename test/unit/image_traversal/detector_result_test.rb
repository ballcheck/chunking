require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class DetectorResultTest < TestCase

    def test_method_colour_detected?
      assert Detector::Result.new( true ).colour_detected?
      assert !Detector::Result.new( false ).colour_detected?
    end

  end
end
