require 'thread'
require 'peach'

class TwentyFortyEight::Runner
  def initialize local, debug = false
    @driver_clazz = local ? TwentyFortyEight::LocalDriver : TwentyFortyEight::WebGameDriver
    @debug = debug

    @report_mutex, @winning_scores, @losing_scores = Mutex.new, [], []
  end

  def report outcome, score, largest_tile_value
    @report_mutex.synchronize do
      trial_number = @winning_scores.count + @losing_scores.count + 1

      case outcome
      when :won then @winning_scores << score
      else @losing_scores << score
      end

      puts "Trial #{trial_number}: agent #{outcome} with score #{score}; largest tile #{largest_tile_value}"
    end
  end

  def run_trials agent_clazz, trial_count, parallelism = 1
    driver_queue = Queue.new
    parallelism.times{ driver_queue.push @driver_clazz.new }

    trial_count.times.peach(parallelism) do
      driver = driver_queue.pop
      run_trial driver, agent_clazz.new
      driver.reset
      driver_queue << driver
    end

    driver_queue.size.times{ driver_queue.pop.close }

    puts "--- Results ---"
    puts "Average score: #{(@winning_scores+@losing_scores).reduce(:+).to_f/trial_count}"
    puts

    puts "Wins: #{@winning_scores.count} (#{@winning_scores.count.to_f*100/trial_count}%)"""
    if @winning_scores.count > 0
      puts "Highest winning score: #{@winning_scores.max}"
      puts "Average winning score: " + (@winning_scores.reduce(:+).to_f / @winning_scores.count).to_s
    end
    puts ""

    puts "Losses: #{@losing_scores.count} (#{@losing_scores.count.to_f*100/trial_count}%)"
    if @losing_scores.count > 0
      puts "Highest losing score: #{@losing_scores.max}"
      puts "Average losing score: " + (@losing_scores.reduce(:+).to_f / @losing_scores.count).to_s
    end
  end

  def run_trial driver, agent
    while true
      if @debug
        puts driver.gameboard.to_s
        gets
      end

      move = agent.next_move driver.gameboard
      puts "moving #{move}..." if @debug
      driver.send_move move
      
      if driver.gameboard.won?
        report :won, driver.gameboard.score, driver.gameboard.largest_tile_value
        break
      elsif driver.gameboard.lost?
        report :lost, driver.gameboard.score, driver.gameboard.largest_tile_value
        break
      end
    end
  end
end
