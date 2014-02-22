require File.expand_path( "../test_helper.rb", __FILE__ )
module ImageTraversal
  class BoundaryTest < TestCase

    def test_initialize
      # mock params
      axis, index, absolute_index = stub( "axis" ), stub( "index" ), stub( "absolute_index" )

      # then...
      b = Boundary.new( axis, index, absolute_index )
      assert_equal [ axis, index, absolute_index ], [ b.axis, b.index, b.absolute_index ]
    end
  end
end
