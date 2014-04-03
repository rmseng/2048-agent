class GreedyAgent
  def initialize
  end

  # takes the moves that has the highest score
  def next_move gameboard
    scores = {}
    gameboard.valid_moves.each{ |move| scores[move] = gameboard.move(move).score }
    max_score = scores.values.max

    # if the score wouldn't change, pick a random action
    if max_score == gameboard.score
      gameboard.valid_moves.select{ |move| not gameboard.equal_tile_layout? gameboard.move move }.sample
    else
      scores.invert[max_score]
    end
  end
end