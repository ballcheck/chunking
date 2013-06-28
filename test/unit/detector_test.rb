require "test_helper"

class DetectorTest < ActiveSupport::TestCase

  # ---------------
  # initialisation
  # ---------------

  def test_should_detect_black_by_default
    detector = Chunking::Detector.new
    assert_equal Chunking::Detector::RGB_BLACK, detector.rgb
  end

  # ------------------------
  # instance / class methods
  # ------------------------

  def test_density_reached?
    detector = build_detector( :density => 1 )
    assert !detector.density_reached?( 0 )
    assert detector.density_reached?( 1 )
    assert detector.density_reached?( 2 )
  end

  def test_should_call_detect_colour_as_class_method
    detector = build_detector
    args = stub( "args" )
    img = stub( "img" )
    index = stub( "index" )
    Chunking::Detector.expects( :new ).once.with( args ).returns( detector )
    detector.expects( :detect_colour? ).once.with( img, index )
    Chunking::Detector.detect_colour? img, index, args
  end

  # TODO: this is not a conclusive test.
  def test_color_should_alias_colour
    assert Chunking::Detector.instance_method( :detect_color? ) == Chunking::Detector.instance_method( :detect_colour? )
    assert Chunking::Detector.method( :detect_color? ) == Chunking::Detector.method( :detect_colour? )
  end

end
