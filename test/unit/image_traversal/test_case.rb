require 'test/unit'
require File.expand_path( "../factories.rb", __FILE__ )

module ImageTraversal
  class TestCase < Test::Unit::TestCase
    include Factories
  end
end
