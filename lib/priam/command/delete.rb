module Priam::Command
  module Delete
    def self.run(argv, input_stream=$stdin, output_stream=$stdout)
      params = Priam::Core::Common.parse_opts(argv)
      host = params[:host]
      port = params[:port]
      keyspace = params[:keyspace]
      column_family = params[:column_family]
      super_column = params[:super_column]
      raise_exception_flag = params[:raise_exception_flag]
      check_exist_flag = params[:check_exist_flag]
      output_keys_flag = params[:output_keys_flag]

      client = Cassandra.new(keyspace, "#{host}:#{port}")
      
      Priam.logger.debug "Cluster Name: #{client.cluster_name}"
      Priam.logger.debug "Key Space   : #{keyspace}"
      
      count = 0
      
      while line = input_stream.gets do
        line.chomp!
        key = line
        begin
          if super_column then
            if check_exist_flag && !client.exists?(column_family, super_column, key) then
              Priam.logger.info " column '#{key}' does not exist"
            else
              client.remove(column_family, super_column, key)
              Priam.logger.info " removed column '#{key}'" if output_keys
              count +=1
            end
          elsif column_family then
            if check_exist_flag && !client.exists?(column_family, key) then
              Priam.logger.info " column '#{key}' does not exist"
            else
              client.remove(column_family, key)
              Priam.logger.info " removed column '#{key}'"
              count +=1
            end
          end
        rescue Exception=>e
          if raise_exception_flag then
            raise e
          else
            backtrace = e.backtrace.map{|s| "  #{s}"}.join("\n")
            Priam.logger.warn(" #{e.message}(#{e.class.name}): #{backtrace}")
            next
          end
        end
      end
      
      uri = "cassandra://#{host}:#{port}/#{keyspace}/#{column_family}"
      uri += "/#{super_column}" if super_column
      Priam.logger.info " removed #{count} columns from #{uri}"
    end
  end
end