module Priam::Command
  module Help
    def self.run(argv, input_stream=$stdin, output_stream=$stdout)
      output_stream.puts <<-EOF
usage: priam COMMAND [-h HOST] [-p PORT]
            [--keyspace KEYSPACE] [--column-family COLUMN_FAMILY]
            [--super-column SUPER_COLUMN] [--value-column COLUMN_NAME]
            [--json] [--retry COUNT] [--weight MSEC]
            [--raise-exception] [--unit-size COUNT] [--verbose]
  -h HOST                        cassandra server address. default is localhost. 
  -p PORT                        port number. default is 9160.
  --keyspace KEYSPACE            keyspace.
  --column-family COLUMN_FAMILY  column-family.
  --super-column SUPER_COLUMN    super-column.
  --value-column COLUMN_NAME     column name for each column. default is 'd' only in insert.
  --json                         put column value in json format. default is off.
  --retry COUNT                  max retry count for put/get. default is 0.
  --weight MSEC                  weight time for retry. default is 1000.
  --raise-exception              raise exception. default is off.
  --unit-size COUNT              unit size for log. default is 10000.
  --verbose                      turn on verbose output, with all the available data. default is off.
      EOF
      return 0
    end
  end
end
