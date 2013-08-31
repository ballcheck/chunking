require 'test/unit'
require File.expand_path( "../factories.rb", __FILE__ )

module Chunking
  class TestCase < Test::Unit::TestCase
    include Factories
  end
end
