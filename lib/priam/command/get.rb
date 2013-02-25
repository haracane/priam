module Priam::Command
  module Get
    def self.run(argv, input_stream=$stdin, output_stream=$stdout)
      params = Priam::Core::Common.parse_opts(argv)
      host = params[:host]
      port = params[:port]
      keyspace = params[:keyspace]
      column_family = params[:column_family]
      super_column = params[:super_column]
      name = params[:value_column]
      with_key_flag = params[:with_key_flag]

      client = Cassandra.new(keyspace, "#{host}:#{port}")
      
      Priam.logger.debug "Cluster Name: #{client.cluster_name}"
      Priam.logger.debug "Key Space   : #{keyspace}"
      
      key_list = []
      count = 0
      
      while line = input_stream.gets do
        key = line.chomp
        key_list.push key
        if key.nil? || key == '' then
          output_stream.puts
          next
        end
      
        record = Priam.get_column(client, column_family, super_column, key, params)    

        if with_key_flag
          output_stream.print "#{key}\t"
        end
        
        if name then
          output_stream.puts "#{record[name]}"
        else
          output_stream.puts record.to_json
        end
        count += 1
        if count % 10 == 0 then
          Priam.logger.info " GET [#{key_list.join(',')}]"
          key_list.clear
        end
      end
      
      if key_list != [] then
        Priam.logger.info " GET [#{key_list.join(',')}]"
      end

      uri = "cassandra://#{host}:#{port}/#{keyspace}/#{column_family}"
      uri += "/#{super_column}" if super_column
      Priam.logger.info " got #{count} columns from #{uri}"
    end
  end
end
