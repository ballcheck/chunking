module ImageTraversal
  module Factories
    def build_image( size = 1 )
      img = stub_everything( "image", :size => size )
      return img
    end

    def build_run
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
