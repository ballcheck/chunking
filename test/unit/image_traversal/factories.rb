module ImageTraversal
  module Factories
    def build_image( size = 1 )
      return ImageTraversal.image_adapter_class.factory( size, size )
    end

    def build_run
      Detector::Run.any_instance.stubs( :determine_initial_state )
      run = Detector::Run.new
      # ensure that when a run is created in 'detect_boundary' this run (the one
      # that was created with *args) is returned
      Detector::Run.stubs( :new ).returns( run )
      return run
    end

    # TODO: args should be first argument, otherwise lots of call have to pass in nil
    # could have seperate method - build_detector_with_stubbed_image
    def build_detector( image = nil, args = {} )
      detector = Detector.factory( args )
      detector.stubs( :retrieve_image => image ) if image
      return detector
    end
  end
end
