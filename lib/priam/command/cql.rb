require "priam/command/cql/create"

module Priam::Command
  module Cql
    def self.run(argv, input_stream=$stdin, output_stream=$stdout)
      command = argv.shift
      case command
      when "create"
        exit_code = Priam::Command::Cql::Create.run(argv) || 0
      else
        STDERR.puts "Invalid cql command: '#{command}'"
        exit_code = 1
      end
      return exit_code
    end
  end
end