module ImageTraversal
  module Factories
    def build_image( size = 1 )
      img = stub_everything( "image", :size => size )
      return img
    end

    def build_run( detector = nil, image = nil )
      DetectorRun.any_instance.stubs( :determine_initial_state )
      run = DetectorRun.new( detector, image )
      # ensure that when a run is created in 'detect_boundary' this run (the one
      # that was created with *args) is returned
      DetectorRun.stubs( :new ).returns( run )
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
