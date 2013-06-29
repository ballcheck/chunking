ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require "debugger"
Dir.glob(Rails.root.to_s + '/lib/chunking/*.rb', &method( :require ) )

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def build_detector( args = {} )
    args[:size] = args.include?( :size ) ? args[:size] : 1
    Chunking::Detector.new( args )
  end
end

require 'mocha/setup'
