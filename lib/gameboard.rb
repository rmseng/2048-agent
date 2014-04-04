class TwentyFortyEight::Gameboard
  class Tile
    attr_reader :row, :column, :value

    def initialize row, column, value
      @row, @column, @value = row, column, value
    end

    def == other_tile
      @row == other_tile.row and @column == other_tile.column and @value == other_tile.value
    end
  end

  ValidMoves = [:left, :right, :up, :down].freeze

  TileValue = /tile-(?<value>[0-9]+)/.freeze
  TilePosition = /tile-position-(?<col>[0-9]+)-(?<row>[0-9]+)/.freeze

  attr_reader :size, :score

  def self.create_2d_square_array size
    arr = []
    size.times do |i|
      arr[i] = size.times.reduce([]){ |a,i| a << nil }
    end
    arr
  end

  # creates a completely empty gameboard
  def self.create_empty size
    TwentyFortyEight::Gameboard.new size, TwentyFortyEight::Gameboard.create_2d_square_array(size)
  end

  # creates gameboard given input from Selenium
  def self.create_from_webpage size, element_classes, score
    board = TwentyFortyEight::Gameboard.create_2d_square_array size

    element_classes.each do |classes|
      classes = classes.split ' '

      value = TileValue.match(classes.find{ |c| c =~ TileValue })[:value].to_i

      tile_position_match = TilePosition.match(classes.find{ |c| c =~ TilePosition })
      row, col = tile_position_match[:row].to_i - 1, tile_position_match[:col].to_i - 1

      # need to take max value because game preserves 'component' tiles
      current_value = board[row][col]
      board[row][col] = value if current_value.nil? or current_value < value
    end

    TwentyFortyEight::Gameboard.new size, board, score
  end

  # sets up a new gameboard; game is initialized according to 2048 rules if board parameter is nil
  def initialize size = 4, board = nil, score = 0
    @size, @board, @score = size, board, score

    # if we have to set up our own board
    if @board.nil?
      @board = TwentyFortyEight::Gameboard.create_2d_square_array size
      2.times{ add_random_tile }
    else
      @board = []
      board.each_index{ |r| @board[r] = Array.new board[r] }
    end
  end

  # there's an argument to be made for excluding moves that would not change game state
  def valid_moves
    ValidMoves
  end

  def clone
    TwentyFortyEight::Gameboard.new @size, @board, @score
  end

  # returns a copy of the gameboard
  def move direction, insert_random = false
    board = case direction
    when :left  then clone.left_shift
    when :up    then clone.rotate_ccw.left_shift.rotate_cw
    when :right then clone.rotate_ccw.rotate_ccw.left_shift.rotate_cw.rotate_cw
    when :down  then clone.rotate_cw.left_shift.rotate_ccw
    else raise 'InvalidDirectionError'
    end

    board.add_random_tile if insert_random and not equal_tile_layout? board

    board
  end

  # true if move would transition board state at all; false otherwise
  def would_tiles_move? direction
    not equal_tile_layout? move direction
  end

  def == other_board
    equal_tile_layout? other_board
  end

  def equal_tile_layout? other_board
    return false unless @size == other_board.size

    (0..@size-1).each do |r|
      (0..@size-1).each do |c|
        return false if get_value(r,c) != other_board.get_value(r,c)
      end
    end

    true
  end

  def board_full?
    @board.each{ |r| return false if r.include? nil }
    true
  end

  def won?
    @board.each{ |r| return true if r.include? 2048 }
    false
  end
  
  def lost?
    return false unless board_full?

    # horizontal tile equality checks
    (0..@size-1).each do |r|
      (0..@size-2).each do |c|
        return false if get_value(r,c) == get_value(r,c+1)
      end
    end

    # vertical tile equality checks
    (0..@size-1).each do |c|
      (0..@size-2).each do |r|
        return false if get_value(r,c) == get_value(r+1,c)
      end
    end    

    true
  end

  def horizontal_pairs
    Enumerator.new do |y|
      (0..@size-1).each do |r|
        (0..@size-2).each do |c|
          y << [Tile.new(r,c,get_value(r,c)), Tile.new(r,c+1,get_value(r,c+1))]
        end
      end
    end
  end

  def vertical_pairs
    Enumerator.new do |y|
      (0..@size-1).each do |c|
        (0..@size-2).each do |r|
          y << [Tile.new(r,c,get_value(r,c)), Tile.new(r+1,c,get_value(r+1,c))]
        end
      end
    end
  end

  def tiles
    Enumerator.new do |y|
      (0..@size-1).each do |r|
        (0..@size-1).each do |c|
          y << Tile.new(r, c, get_value(r,c))
        end
      end
    end
  end

  def adjacent_tiles r, c
    Enumerator.new do |y|
      (-1..1).each do |r_d|
        (-1..1).each do |c_d|
          next if r_d == c_d
          r_n = r + r_d
          c_n = c + c_d
          next if r_n < 0 or c_n < 0
          next if r_n > (@size-1) or c_n > (@size-1)
          y << Tile.new(r_n, c_n, get_value(r_n, c_n))
        end
      end
    end
  end

  def largest_tile_value
    values = []
    tiles.each do |tile|
      values << tile.value
    end
    values.compact.max
  end

  def to_s
    puts
    @board.each do |row|
      row.each do |i|
        str = (i.nil? ? '-' : i).to_s
        print str.center 6
      end
      puts
      puts
    end
    puts " Score: #{@score}"
    nil
  end

  def free_cells
    cells = []
    @board.each_index do |r|
      @board[r].each_index do |c|
        cells << Tile.new(r,c,nil) if get_value(r,c).nil?
      end
    end
    cells
  end

  def get_value row, col
    check_coordinates row, col
    @board[row][col]
  end

  protected
  def set_value row, col, val
    check_coordinates row, col
    @board[row][col] = val
  end
  
  def check_coordinates row, col
    raise "InvalidCoordinateError: #{row},#{col}" unless (0..@size-1).include?(row) and (0..@size-1).include?(col)
  end

  def add_random_tile
    return if board_full?
    tile = free_cells.sample
    v = rand(10) < 9 ? 2 : 4
    set_value tile.row, tile.column, v
  end

  def score= score
    @score = score
  end

  def rotate_cw
    new_board = TwentyFortyEight::Gameboard.new @size, nil, @score

    (0..@size-1).each do |r|
      (0..@size-1).each do |c|
        new_board.set_value c, (@size - (r + 1)), get_value(r, c)
      end
    end

    new_board
  end

  def rotate_ccw
    new_board = TwentyFortyEight::Gameboard.new @size, nil, @score

    (0..@size-1).each do |r|
      (0..@size-1).each do |c|
        new_board.set_value (@size - (c + 1)), r, get_value(r, c)
      end
    end

    new_board
  end

  def left_shift
    (0..@size-1).each do |row|
      # tiles can't combine more than once in one move
      combined_cols = []

      # find first non-nil element to shift
      (1..@size-1).each do |col|
        next if get_value(row,col).nil?

        # shift element to next non-empty square
        new_col = col
        new_col -= 1 while new_col > 0 and get_value(row, new_col - 1).nil?
        
        # possibly set element to new column
        if new_col != col
          set_value row, new_col, get_value(row, col)
          set_value row, col, nil
        end

        # if it's equal to its neighbor to the left, double it
        if (new_col - 1 >= 0) and get_value(row, new_col - 1) == get_value(row, new_col) and not combined_cols.include?(new_col - 1)
          set_value row, new_col - 1, get_value(row, new_col-1)*2
          set_value row, new_col, nil
          @score += get_value row, new_col - 1
          combined_cols << (new_col - 1)
        end
      end
    end

    self
  end
end
