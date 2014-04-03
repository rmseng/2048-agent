class SampleAgent
  def initialize
    @counter = 0
  end

  # just cycles through the four available moves
  def next_move gameboard
    @counter += 1
    @counter = 0 if @counter == 4
    gameboard.valid_moves[@counter]
  end
end