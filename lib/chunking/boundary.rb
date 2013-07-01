# TODO: untested
module Chunking
  class Boundary
    attr_accessor :index, :axis
    def initialize( axis, index )
      @axis = axis
      @index = index
    end

    def nil_boundary?
      false
    end
  end

  class NilBoundary
    def nil_boundary?
      true
    end
  end
end
