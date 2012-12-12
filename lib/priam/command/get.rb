module Priam::Command
  module Get
    
    def self.get(client, column_family, super_column, key, options={})
      raise_exception_flag = options[:raise_exception_flag]
      retry_max_count = options[:retry_max_count] || 0
      weight_second = options[:weight_second] || 1
      
      retry_count = 0
      begin
        if super_column
          record = client.get(column_family, super_column, key)
        else
          record = client.get(column_family, key)
        end
      rescue Exception => e
        if retry_max_count <= retry_count then
          if raise_exception_flag then
            raise e
          else
            backtrace = e.backtrace.map{|s| "  #{s}"}.join("\n")
            Priam.logger.warn(" #{e.message}(#{e.class.name}): #{backtrace}")
            return {}
          end
        else
          retry_count += 1
          Priam.logger.warn(" #{e.message}(#{e.class.name})")
          Priam.logger.info(" retry(#{retry_count})")
          sleep(weight_second) if weight_second
          retry
        end
      end
      return record
    end
    
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
      
        record = self.get(client, column_family, super_column, key, params)    
        
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
