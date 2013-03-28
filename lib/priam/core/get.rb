module Priam::Core
  module Get
    def self.get_column(client, column_family, super_column, key, options={})
      raise_exception_flag = options[:raise_exception_flag]
      retry_max_count = options[:retry_max_count] || 5
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
            Priam.logger.warn("(EXCEPTION)#{e.message}(#{e.class.name}): #{e.backtrace.map{|s| "  #{s}"}.join("\n")}")
            return {}
          end
        else
          retry_count += 1
          Priam.logger.warn("(EXCEPTION)#{e.message}(#{e.class.name}): #{e.backtrace.map{|s| "  #{s}"}.join("\n")}")
          Priam.logger.warn("retry(#{retry_count})")
          sleep(weight_second) if weight_second
          retry
        end
      end
      return record
    end
  end
end
