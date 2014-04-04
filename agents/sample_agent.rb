class SampleAgent
  def initialize
    @counter = 0
  end

  # cycles through all available moves
  def next_move gameboard
    @counter += 1
    @counter = 0 if @counter == gameboard.valid_moves.count
    gameboard.valid_moves[@counter]
  end
end