module ImageTraversal
  module Factories
    def build_image( size_or_width = 1, height = nil )
      width, height = height ? [ size_or_width, height ] : [ size_or_width, size_or_width ]
      return ImageTraversal.image_adapter_class.factory( width, height )
    end

    def build_image_with_stubbed_size( axis, size )
      image = build_image
      image.stubs( :size ).with( axis ).returns( size )
      return image
    end

    def build_run
      return Detector::Run.new
    end

    def build_result( *args )
      return Detector::Result.new( *args )
    end

    def build_detector( args = {} )
      return Detector.factory( args )
    end

    def given_a_random_rational
      Rational( (1..100).to_a.sample / 100.0 )
    end

    def given_a_random_rgba
      rgb = Array.new( 4 ){ rand Palette.max_colour_value+1 }
    end
  end
end
