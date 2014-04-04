class GreedyAgent
  def initialize
  end

  # takes the moves that has the highest score
  def next_move gameboard
    result_pairs = []

    gameboard.valid_moves.each do |move|
      new_gameboard = gameboard.move move
      result_pairs << { score: new_gameboard.score, move: move } unless gameboard.equal_tile_layout? new_gameboard
    end

    result_pairs.sort_by{ |s| s[:score] }.reverse.first[:move]
  end
end