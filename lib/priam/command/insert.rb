module Priam::Command
  module Insert
    def self.run(argv, input_stream=$stdin, output_stream=$stdout)
      params = Priam::Core::Common.parse_opts(argv)
      host = params[:host]
      port = params[:port]
      keyspace = params[:keyspace]
      column_family = params[:column_family]
      super_column = params[:super_column]
      raise_exception_flag = params[:raise_exception_flag]
      unit_size = params[:unit_size]
      value_column = params[:value_column] || "d"
      weight_second = params[:weight_second]
      retry_max_count = params[:retry_max_count]
      count_log_path = params[:count_log_path]
      json_flag = params[:json_flag]

      keyspace = argv.shift if 0 < argv.length
      column_family = argv.shift if 0 < argv.length
      super_column = argv.shift if 0 < argv.length
      
      if keyspace.nil? then
        Priam.logger.error " keyspace is not specified"
        exit 1
      end
      
      if column_family.nil? then
        Priam.logger.error " column_family is not specified"
        exit 1
      end
      
      client = Cassandra.new(keyspace, "#{host}:#{port}")
      
      exit 1 if client.nil?

      Priam.logger.debug "Cluster Name: #{client.cluster_name}"
      Priam.logger.debug "Key Space   : #{keyspace}"
      
      column_family = column_family.intern
      
      # client.remove(column_family, target_date)
      
      if !super_column.nil? then
        exist_flag = false
        
        begin
          exist_flag = client.exists?(column_family, super_column)
        rescue Exception=>e
          exist_flag = false
        end
        
        if !exist_flag then
          Priam.logger.info " create super column cassandra://#{host}:#{port}/#{keyspace}/#{column_family}/#{super_column}]"
          client.insert(column_family, super_column, {})
        end
        Priam.logger.info " insert into cassandra://#{host}:#{port}/#{keyspace}/#{column_family}/#{super_column}"
      else
        Priam.logger.info " insert into cassandra://#{host}:#{port}/#{keyspace}/#{column_family}"
      end
      
      
      count = 0
      while line = input_stream.gets do
        line.chomp!
        next if line == ''
        record = line.chomp.split(/\t/, 2)
      #  record = record.map{|val| DbEscape.db_unescape(val)}
        key = record.shift
        value = record.shift || ""
        
      #  STDERR.puts "insert #{record.to_json}"
        retry_count = 0
        begin
      #    STDERR.puts "#{retry_count} #{retry_max_count}"
      #    raise "Test Error"
          if json_flag
            column = JSON.parse(value)
          else
            column = {value_column=>value}
          end
          if super_column then
            client.insert(column_family, super_column, {key=>column})
          else
            client.insert(column_family, key, column)
          end
          count += 1
          if count % unit_size == 0 then
            Priam.logger.info " inserted #{count} columns"
          end
        rescue Exception=>e
          if retry_max_count <= retry_count then
            if raise_exception_flag then
              raise e
            else
              backtrace = e.backtrace.map{|s| "  #{s}"}.join("\n")
              Priam.logger.warn(" #{e.message}(#{e.class.name}): #{backtrace}")
            end
          else
            retry_count += 1
            Priam.logger.warn(" #{e.message}(#{e.class.name})")
            Priam.logger.info(" retry(#{retry_count})")
            sleep(weight_second) if weight_second
            retry
          end
        end
        sleep(weight_second) if weight_second
      end
      
      if count_log_path
        open(count_log_path, "w") do |f|
          f.puts count
        end
      end
      
      uri = "cassandra://#{host}:#{port}/#{keyspace}/#{column_family}"
      uri += "/#{super_column}" if super_column
      Priam.logger.info " inserted #{count} columns into #{uri}"
    
    end
  end
end