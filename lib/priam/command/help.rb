module Priam::Command
  module Help
    def self.run(argv, input_stream=$stdin, output_stream=$stdout)
      output_stream.puts <<-EOF
usage: priam COMMAND [-h HOST] [-p PORT]
            [--keyspace KEYSPACE] [--column-family COLUMN_FAMILY]
            [--super-column SUPER_COLUMN] [--value-column COLUMN_NAME]
            [--retry COUNT] [--weight MSEC]
            [--raise-exception] [--unit-size COUNT] [--verbose]
  -h HOST                        cassandra server address. default is localhost. 
  -p PORT                        port number. default is 9160.
  --keyspace KEYSPACE            keyspace.
  --column-family COLUMN_FAMILY  column-family.
  --super-column SUPER_COLUMN    super-column.
  --value-column COLUMN_NAME     column name for each column.
  --retry COUNT                  max retry count for put/get.
  --weight MSEC                  weight time for retry.
  --raise-exception              raise exception.
  --unit-size COUNT              unit size for log.
  --verbose                      turn on verbose output, with all the available data.
      EOF
      return 0
    end
  end
end
