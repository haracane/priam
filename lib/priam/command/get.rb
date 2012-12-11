module Priam::Command
  module Get
    def self.run(argv, input_stream=$stdin, output_stream=$stdout)
      params = Priam::Core::Common.parse_opts(argv)
      host = params[:host]
      port = params[:port]
      keyspace = params[:keyspace]
      column_family = params[:column_family]
      super_column = params[:super_column]
      name = params[:name]
      
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
      
        begin
          if super_column then
            record = client.get(column_family, super_column, key)
          else
            record = client.get(column_family, key)
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
        rescue Exception => e
          raise e.class, "#{e.message}, key list = #{key_list.inspect}"
        end
      end
      
      if key_list != [] then
        Priam.logger.info " GET [#{key_list.join(',')}]"
      end
    end
  end
end
