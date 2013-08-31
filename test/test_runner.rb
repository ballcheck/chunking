require 'active_support'
require 'test/unit'

class Rails
  def self.root
    "/home/tim/rails_projects/testing_project/"
  end
end

#require File.expand_path( "../test_helper", __FILE__ )
Dir.glob( File.expand_path( "../unit/chunking/**/*.rb", __FILE__ ), &method( :load ) )
require Rails.root.to_s << "/lib/chunking/chunking"

class ActiveSupport::TestCase
  include Chunking::Factories
end

#Test::Unit::AutoRunner.run
