require 'selenium-webdriver'

class TwentyFortyEight::WebGameDriver
  attr_reader :gameboard, :move_count

  def initialize game_size = 4, delay = 0.25
    @game_size, @delay = game_size, delay
    @driver = Selenium::WebDriver.for :firefox
    reset
  end

  def reset
    @move_count = 0
    @driver.navigate.to 'http://gabrielecirulli.github.io/2048/'
    @driver.find_element(:class, 'restart-button').click
    sleep 1
    @gameboard_elt = @driver.find_element(:class, 'container')
    reload_gameboard
  end

  def send_move direction
    raise 'InvalidMoveException' unless @gameboard.valid_moves.include? direction
    @gameboard_elt.send_keys direction
    sleep @delay
    @move_count += 1
    reload_gameboard
  end

  def close
    @driver.close
  end

  private
  def reload_gameboard
    @gameboard = TwentyFortyEight::Gameboard.create_from_webpage @game_size, @driver.find_elements(:class, 'tile').map{ |e| e.attribute('class') }, @driver.find_element(:class, 'score-container').text.to_i
  end
end
