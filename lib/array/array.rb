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

  # TODO: this could be prettier.
  # rotate 90 degrees.
  def rotate( anti_clockwise = false )
    new = []
    self.first.length.times do |col|
      row = self.map{ |x| x[col] }
      row.reverse! unless anti_clockwise
      new.push( row )
    end
    new.reverse! if anti_clockwise
    return new
  end
end
