module Priam::Command::Cql
  module Create
    def self.run(argv, input_stream=$stdin, output_stream=$stdout)
      params = Priam::Core::Common.parse_opts(argv)
      replication_factor = params[:replication_factor]
      keyspace = params[:keyspace]
      column_family = params[:column_family]
      super_column = params[:super_column]
      
      if keyspace
        output_stream.puts <<-EOF
create keyspace #{keyspace}
  with strategy_options={replication_factor:#{replication_factor}}
  and placement_strategy = 'org.apache.cassandra.locator.SimpleStrategy';
        EOF
        if column_family
          output_stream.puts <<-EOF
use #{keyspace};
create column family #{column_family}
  with column_type = Standard -- or Super
  and comparator = BytesType
  and subcomparator = BytesType;
        EOF
        end
      end
      

    end
  end
end