require "spec_helper"

describe Priam::Core::Common do
  describe ".parse_opts(argv)" do
    context "when argv = []" do
      it "should return defalut hash" do
        result = Priam::Core::Common.parse_opts([])
        result[:host].should == "localhost"
        result[:port].should == 9160
        result[:raise_exception_flag].should == false
        result[:value_column].should == "d"
        result[:retry_max_count].should == 0
        result[:check_exist_flag].should == false
        result[:output_keys_flag].should == false
        result[:replication_factor].should == 1
        result[:verbose_flag].should == false
      end
    end

    argv = ("-h cassandra-server -p 19160" \
      + " --keyspace KeySpace --column-family ColumnFamily" \
      + " --super-column SuperColumn --name name" \
      + " --raise-exception --unit-size 10 --value-column value_column" \
      + " --weight 11000 --retry 12 --count-log count.log" \
      + " --check-exist --output-keys --replication-factor 13 --verbose").split(/ /)

    context "when argv = #{argv.inspect}" do
      it "should return valid hash" do
        result = Priam::Core::Common.parse_opts(argv)
        result[:host].should == "cassandra-server"
        result[:port].should == 19160
        result[:keyspace].should == "KeySpace"
        result[:column_family].should == "ColumnFamily"
        result[:super_column].should == "SuperColumn"
        result[:name].should == "name"
        result[:raise_exception_flag].should == true
        result[:unit_size].should == 10
        result[:value_column].should == "value_column"
        result[:weight_second].should == 11
        result[:retry_max_count].should == 12
        result[:count_log_path].should == "count.log"
        result[:check_exist_flag].should == true
        result[:output_keys_flag].should == true
        result[:replication_factor].should == 13
        result[:verbose_flag].should == true
      end
    end
  end
end
