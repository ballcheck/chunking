ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require "debugger"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def build_image( size = 1 )
    img = stub_everything( "image", :size => size )
    return img
  end

  def build_run( *args )
    run = Chunking::DetectorRun.new( *args )
    # ensure that when a run is created in 'detect_boundary' this run (the one
    # that was created with *args) is returned
    Chunking::DetectorRun.stubs( :new ).once.returns( run )
    return run
  end

  def build_detector( args = {} )
    args[:size] = args.include?( :size ) ? args[:size] : 1
    Chunking::Detector.new( args )
  end
end

require 'mocha/setup'
