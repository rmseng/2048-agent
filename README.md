2048-agent
==========

Create and run agents to play Gabriele Cirulli's [2048](http://gabrielecirulli.github.io/2048/)!

Get running
------------------
You'll need Firefox and a Ruby interpreter (ruby, jruby, etc)

1. `git clone https://github.com/rmseng/2048-agent.git`
2. `bundle install`
3. `ruby twenty_forty_eight.rb --help`
4. `ruby twenty_forty_eight.rb -a GreedyAgent -t 2`

Get developing
------------------
1. Create a file for your new agent in the agents directory
2. Implement the agent with:
  * `initialize` with any setup your agent needs
  * `next_move` that takes the gameboard as its parameter and returns your agent's move

  Check `greedy_agent.rb` or `sample_agent.rb` in the agents directory for examples.
3. `ruby twenty_forty_eight.rb -a <YourAgent>`
4. Have fun!

Tips
------------------
TwentyFortyEight can help you run parallel trials for your agent, monitor its decisions, and even run it locally for a big speed boost.  See your options: `ruby twenty_forty_eight.rb --help`

TwentyFortyEight::Gameboard comes with many useful methods.  Some of these methods return or yield TwentyFortyEight::Gameboard::Tile objects, which have attributes row, column, and value (which use zero-based coordinates.)
  Here are some of Gameboard's useful methods:
  
  * `size` self-explanatory
  * `score` self-explanatory
  * `valid_moves` returns [:left, :right, :up, :down]
  * `move(direction, insert_random = false)` returns a new copy of the gameboard with the move simulated (with or without adding a new random tile)
  * `would_tiles_move?` tells you if a move will change the game state
  * `==` compares tile values and positions (not scores)
  * `board_full?` returns true even if there is a possible combination to be made
  * `won?` self-explanatory
  * `lost?` self-explanatory
  * `tiles` enumerates each Tile
  * `horizontal_pairs` enumerates horizontal pairs of Tiles
  * `vertical_pairs` enumerates vertical pairs of Tiles
  * `adjacent_tiles(row, col)` enumerates the 2, 3, or 4 immediately adjacent Tiles
  * `largest_tile_value` returns the value of the highest-valued tile
  * `to_s` prints a ASCII representation of the gameboard
  * `free_cells` returns an array of Tiles with nil (empty) values
  * `get_value(row, col)` returns either nil or an integer, depending on the presence and value of a Tile

Starting a new trial means a new agent will be instantiated.  If you want to write a learning agent, you could use class variables, but be sure to synchronize them if you're testing them in parallel.

After you think you've got an agent worthy of extensive testing, try using the 'local' option to simulate many games locally (without running Firefox.)  TwentyFortyEight will simulate games of 2048 and collect the results for you.

Contributing
------------------
If you find a bug, please submit a pull request - I'll happily confirm and merge it.