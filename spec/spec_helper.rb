if RUBY_VERSION <= '1.8.7'
else
  require "simplecov"
  require "simplecov-rcov"
  SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
  SimpleCov.start
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'priam'
require "tempfile"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end

module Priam
  PRIAM_HOME = File.expand_path(File.dirname(__FILE__) + "/..")
  BIN_DIR = "#{PRIAM_HOME}/bin"
  LIB_DIR = "#{PRIAM_HOME}/lib"
  RUBY_CMD = "/usr/bin/env ruby -I #{LIB_DIR}"
  REDIRECT = {:stderr=>"2> /dev/null"}
end

Priam.logger = Logger.new(STDERR)
if File.exist?('/tmp/priam.debug') then
  Priam.logger.level = Logger::DEBUG
  Priam::REDIRECT[:stderr] = nil
else
  Priam.logger.level = Logger::ERROR
  Priam::REDIRECT[:stderr] = "2> /dev/null"
end

module PriamTest
  def self.create_test_schema
    cql = <<-EOF
create keyspace PriamTest
  with strategy_options={replication_factor:1}
  and placement_strategy = 'org.apache.cassandra.locator.SimpleStrategy';
use PriamTest;
create column family PriamCF
  with column_type = Standard -- or Super
  and comparator = BytesType
  and subcomparator = BytesType;
    EOF
    tmpfile = Tempfile.new("spec_helper")
    tmpfile.puts cql
    tmpfile.close
    hostname = `hostname`.chomp
    `/usr/lib/cassandra/bin/cassandra-cli -h #{hostname} -p 9160 -f #{tmpfile.path} 2>/dev/null`
    tmpfile.unlink
  end
  
  def self.drop_test_schema
    cql = "drop keyspace PriamTest"
    tmpfile = Tempfile.new("spec_helper")
    tmpfile.puts cql
    tmpfile.close
    hostname = `hostname`.chomp
    `/usr/lib/cassandra/bin/cassandra-cli -h #{hostname} -p 9160 -f #{tmpfile.path} 2>/dev/null`
    tmpfile.unlink
  end
end