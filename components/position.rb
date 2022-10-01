module Component
  module Position
    attr_accessor :x, :y
    
    def position
      [@x, @y]
    end
  end
end