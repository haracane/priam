module Priam::Core
  module Common
    def self.parse_opts(argv)
      host = 'localhost'
      port = 9160
      raise_exception_flag = false
      
      value_column = "d"
      unit_size = 10000
      retry_max_count = 0

      check_exist_flag = false
      output_keys_flag = false
      
      next_argv = []
      
      while 0 < argv.size do
        val = argv.shift
        case val
        when '-h'
          host = argv.shift
        when '-p'
          port = argv.shift.to_i
        when '--keyspace'
          keyspace = argv.shift
        when '--column-family'
          column_family = argv.shift
        when '--super-column'
          super_column = argv.shift
        when '--name'
          name = argv.shift
        when '--raise-exception'
          raise_exception_flag = true
        when '--unit-size'
          unit_size = argv.shift.to_i
        when '--value-column'
          value_column = argv.shift
        when '--weight'
          weight_second = argv.shift.to_f / 1000
        when '--retry'
          retry_max_count = argv.shift.to_i
        when '--count-log'
          count_log_path = argv.shift
        when '--check-exist'
          check_exist_flag = true
        when '--output-keys'
          output_keys_flag = true
        else 
          next_argv.push val
        end
      end
      argv.push(*next_argv)
      
      return {
        :host=>host,
        :port=>port,
        :keyspace=>keyspace,
        :column_family=>column_family,
        :super_column=>super_column,
        :name=>name,
        :raise_exception_flag=>raise_exception_flag,
        :unit_size=>unit_size,
        :value_column=>value_column,
        :weight_second=>weight_second,
        :retry_max_count=>retry_max_count,
        :count_log_path=>count_log_path,
        :check_exist_flag=>check_exist_flag,
        :output_keys_flag=>output_keys_flag
      }
    end
  end
end