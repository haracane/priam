require "spec_helper"

describe "bin/priam" do
  before :all do
    @stderr_dst = Priam::REDIRECT[:stderr]
    PriamTest.create_test_schema()
    @hostname = `hostname`.chomp
  end
  
  after :all do
    PriamTest.drop_test_schema()
  end

  before :each do
    input = [
      ["key1", "val1"],
    ]
    tmpfile = Tempfile.new("bin_priam")
    input.each do |record|
      tmpfile.puts record.join("\t")
    end
    tmpfile.close
    `cat #{tmpfile.path} | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam insert --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 2> /dev/null`
    tmpfile.unlink
  end

  context "when command = cql" do
    context "when sub-command = create" do
      it "should output create cql" do
        result = `#{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam cql create --keyspace PriamTest --column-family PriamCF`
        result.should =~ /create keyspace PriamTest/
        result.should =~ /create column family PriamCF/
      end
    end
  end
  
  context "when command = help" do
    it "should output help" do
      result = `#{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam help`
      result.length.should > 0
    end
  end
  
  context "when command = insert" do
    context "with json option" do
      it "should insert values" do
        input = [
          ["key3", {"data"=>"val3"}.to_json],
          ["key4", {"data"=>"val4"}.to_json]
        ]
        tmpfile = Tempfile.new("bin_priam")
        input.each do |record|
          tmpfile.puts record.join("\t")
        end
        tmpfile.close
        `cat #{tmpfile.path} | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam insert --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --json --verbose #{@stderr_dst}`
        tmpfile.unlink
  
        result = `echo key3 | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam get --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --value-column data 2> /dev/null`
        result.chomp!
        result.should == "val3"
        
        result = `echo key4 | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam get --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --value-column data 2> /dev/null`
        result.chomp!
        result.should == "val4"
      end
    end
    context "without json option" do
      it "should insert values" do
        input = [
          ["key1", "val10"],
          ["key2", "val2"]
        ]
        tmpfile = Tempfile.new("bin_priam")
        input.each do |record|
          tmpfile.puts record.join("\t")
        end
        tmpfile.close
        `cat #{tmpfile.path} | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam insert --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --verbose #{@stderr_dst}`
        tmpfile.unlink
  
        result = `echo key1 | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam get --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --name d 2> /dev/null`
        result.chomp!
        result.should == "val10"
        
        result = `echo key2 | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam get --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --name d 2> /dev/null`
        result.chomp!
        result.should == "val2"
      end
    end
  end
  
  context "when command = get" do
    context "without value-column option" do
      context "with with-key option" do
        context "when key&value exists" do
          it "should output json" do
            result = `echo key1 | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam get --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --verbose #{@stderr_dst}`
            result.chomp!
            result.should == '{"d":"val1"}'
          end
        end
      end
      context "without with-key option" do
        context "when key&value exists" do
          it "should output json" do
            result = `echo key1 | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam get --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --with-key --verbose #{@stderr_dst}`
            result.chomp!
            result.should == ["key1", '{"d":"val1"}'].join("\t")
          end
        end
      end
    end
    context "with value-column option" do
      context "when key&value exists" do
        it "should output value" do
          result = `echo key1 | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam get --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --name d --verbose #{@stderr_dst}`
          result.chomp!
          result.should == "val1"
        end
      end
      context "when key&value does not exist" do
        it "should not output value" do
          result = `echo nokey | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam get --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --name d --verbose #{@stderr_dst}`
          result.chomp!
          result.should == ""
        end
      end
      context "when retry option is enabled" do
        it "should output value" do
          result = `echo key1 | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam get --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --name d --retry 5 --weight 1000 --verbose #{@stderr_dst}`
          result.chomp!
          result.should == "val1"
        end
      end
    end
  end

  context "when command = delete" do
    context "when key&value exists" do
      it "should delete key&value" do
        `echo key1 | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam delete --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --verbose #{@stderr_dst}`
        result = `echo key1 | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam get --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --name d 2>/dev/null`
        result.chomp!
        result.should == ""
      end
    end
    
    context "when key&value does not exist" do
      it "should do nothing" do
        `echo nokey | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam delete --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --verbose #{@stderr_dst}`
        result = `echo nokey | #{Priam::RUBY_CMD} -I #{Priam::LIB_DIR} #{Priam::BIN_DIR}/priam get --keyspace PriamTest --column-family PriamCF -h #{@hostname} -p 9160 --name d 2>/dev/null`
        result.chomp!
        result.should == ""
      end
    end
  end

end
