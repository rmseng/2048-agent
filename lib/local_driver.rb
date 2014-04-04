class TwentyFortyEight::LocalDriver
  attr_reader :gameboard, :move_count

  def initialize game_size = 4
    @game_size = game_size
    reset
  end

  def reset
    @move_count = 0
    @gameboard = TwentyFortyEight::Gameboard.new @game_size, nil
  end

  def send_move direction
    raise "InvalidMoveError: #{direction}" unless @gameboard.valid_moves.include? direction
    @move_count += 1
    @gameboard = @gameboard.move direction, true
  end

  def close
  end
end
