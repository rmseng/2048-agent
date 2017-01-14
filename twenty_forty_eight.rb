module TwentyFortyEight end

require './lib/gameboard'
require './lib/local_driver'
require './lib/web_game_driver'
require './lib/runner'
Dir.foreach('agents'){ |fname| require "./agents/#{fname}" if fname =~ /.+\.rb/ }

if __FILE__ == $0
  require 'trollop'

  opts = Trollop::options do
    version "1.0"
    banner <<-EOS
  Write an agent to play 2048!
  EOS

    opt :agent, "Class of agent to run", type: :string
    opt :trials, "Number of trials to run", type: :integer, default: 1
    opt :debug, "'Debugging' mode, enter plays next move"
    opt :local, "Simulate game locally instead of opening Firefox"
    opt :parallelism, "Number of trials to run concurrently", type: :integer, default: 1
  end

  Trollop::die :agent, "must set the agent to run" if opts[:agent].nil?
  Trollop::die :trials, "must be at least 1" if opts[:trials] < 1
  Trollop::die :parallelism, "must be 1 if --debug is set" if opts[:debug] and opts[:parallelism] > 1

  tfe = TwentyFortyEight::Runner.new opts[:local], opts[:debug]
  tfe.run_trials Object.const_get(opts[:agent]), opts[:trials], opts[:parallelism]
end
