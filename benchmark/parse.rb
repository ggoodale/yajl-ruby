# encoding: UTF-8
require 'rubygems'
require 'benchmark'
begin
  require 'yajl_ext'
rescue LoadError
  require 'yajl/ffi'
end
require 'json'
require 'activesupport'

filename = ARGV[0] || 'benchmark/subjects/twitter_search.json'
json = File.new(filename, 'r')

times = ARGV[1] ? ARGV[1].to_i : 1000
puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
Benchmark.bmbm { |x|
  io_parser = Yajl::Parser.new
  io_parser.on_parse_complete = lambda {|obj|} if times > 1
  x.report {
    puts "Yajl::Parser#parse (from an IO)"
    times.times {
      json.rewind
      io_parser.parse(json)
    }
  }
  string_parser = Yajl::Parser.new
  string_parser.on_parse_complete = lambda {|obj|} if times > 1
  x.report {
    puts "Yajl::Parser#parse (from a String)"
    times.times {
      json.rewind
      string_parser.parse(json.read)
    }
  }
  x.report {
    puts "JSON.parse"
    times.times {
      json.rewind
      JSON.parse(json.read, :max_nesting => false)
    }
  }
  x.report {
    puts "ActiveSupport::JSON.decode"
    times.times {
      json.rewind
      ActiveSupport::JSON.decode(json.read)
    }
  }
}
json.close