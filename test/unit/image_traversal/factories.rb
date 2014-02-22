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
      Detector::Run.any_instance.stubs( :determine_initial_state )
      run = Detector::Run.new
      # ensure that when a run is created in 'detect_boundary' this run (the one
      # that was created with *args) is returned
      Detector::Run.stubs( :new ).returns( run )
      return run
    end

    def build_result( *args )
      return Detector::Result.new( *args )
    end

    # TODO: args should be first argument, otherwise lots of call have to pass in nil
    # could have seperate method - build_detector_with_stubbed_image
    # TODO: passing in image is redundant now because were using real images.
    def build_detector( image = nil, args = {} )
      detector = Detector.factory( args )
      detector.stubs( :retrieve_image => image ) if image
      return detector
    end

    def given_a_random_rational
      Rational( (1..100).to_a.sample / 100.0 )
    end
  end
end
