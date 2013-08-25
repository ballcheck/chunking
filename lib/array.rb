class Array

  def invert( axis )
    case axis.to_s
    when "y"
      self.map( &:reverse )
    when "x"
      self.reverse
    end
  end
        
  def flip
    invert( "y" )
  end

  def flop
    invert( "x" )
  end
end
