#-- TODO: module untested.

module Chunking
  class Boundary
    attr_accessor :index, :axis
    def initialize( axis, index )
      # x or y image axis.
      @axis = axis
      # pixel index from top or left edge depending on @axis.
      @index = index
    end
  end
end
