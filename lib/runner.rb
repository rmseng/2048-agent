class TwentyFortyEight::Runner
  def initialize local
    @driver = local ? TwentyFortyEight::LocalDriver : TwentyFortyEight::WebGameDriver
  end

  def run_trials agent, trial_count, debug
    trial_count = trial_count.nil? ? 1 : trial_count.to_i
    driver = @driver.new

    winning_scores, losing_scores = [], []
    
    trial_count.times do |i|
      while true
        if debug
          puts driver.gameboard.to_s
          gets
        end

        move = agent.next_move driver.gameboard
        puts move if debug
        driver.send_move move
        
        if driver.gameboard.won?
          puts "Trial #{i+1}: agent won with score #{driver.gameboard.score}; largest tile #{driver.gameboard.largest_tile_value}"
          winning_scores << driver.gameboard.score
          break
        elsif driver.gameboard.lost?
          puts "Trial #{i+1}: agent lost with score #{driver.gameboard.score}; largest tile #{driver.gameboard.largest_tile_value}"
          losing_scores << driver.gameboard.score
          break
        end
      end

      driver.reset
    end

    driver.close

    puts "--- Results ---"
    puts "Average score: #{(winning_scores+losing_scores).reduce(:+).to_f/trial_count}"
    puts

    puts "Wins: #{winning_scores.count} (#{winning_scores.count.to_f*100/trial_count}%)"""
    if winning_scores.count > 0
      puts "Highest winning score: #{winning_scores.max}"
      puts "Average winning score: " + (winning_scores.reduce(:+).to_f / winning_scores.count).to_s
    end
    puts ""

    puts "Losses: #{losing_scores.count} (#{losing_scores.count.to_f*100/trial_count}%)"
    if losing_scores.count > 0
      puts "Highest losing score: #{losing_scores.max}"
      puts "Average losing score: " + (losing_scores.reduce(:+).to_f / losing_scores.count).to_s
    end
  end
end
