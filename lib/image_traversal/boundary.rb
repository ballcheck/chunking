module ImageTraversal
  class Boundary
    attr_accessor :index, :axis, :absolute_index
    def initialize( axis, index, absolute_index = nil )
      # x or y image axis.
      @axis = axis

      # Pixel index from top/bottom or left/right depending on @axis and invert_direction.
      @index = index

      # Pixel index from top or left depending on @axis.
      @absolute_index = absolute_index || index
    end
  end
end
