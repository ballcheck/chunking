module ImageTraversal
  module Factories
    def build_image( size = 1 )
      img = stub_everything( "image", :size => size )
      return img
    end

    # TODO: lots of tests pass in these 2 attributes, which are no longer required.
    def build_run( detector = nil, image = nil )
      Detector::Run.any_instance.stubs( :determine_initial_state )
      run = Detector::Run.new
      # ensure that when a run is created in 'detect_boundary' this run (the one
      # that was created with *args) is returned
      Detector::Run.stubs( :new ).returns( run )
      return run
    end

    def build_detector( image = nil, args = {} )
      args[:size] = args.include?( :size ) ? args[:size] : 1
      detector = Detector.new( args )
      detector.stubs( :retrieve_image => image ) if image
      return detector
    end
  end
end
