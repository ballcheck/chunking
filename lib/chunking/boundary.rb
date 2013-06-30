# TODO: untested
module Chunking
  class Boundary
    attr_accessor :index
    def initialize( index )
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
