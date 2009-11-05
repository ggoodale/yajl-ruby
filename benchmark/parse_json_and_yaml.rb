# encoding: UTF-8
require 'rubygems'
require 'benchmark'
begin
  require 'yajl_ext'
rescue LoadError
  require 'yajl/ffi'
end
require 'json'
require 'yaml'

# JSON section
filename = 'benchmark/subjects/ohai.json'
json = File.new(filename, 'r')

times = ARGV[0] ? ARGV[0].to_i : 1000
puts "Starting benchmark parsing #{File.size(filename)} bytes of JSON data #{times} times\n\n"
Benchmark.bmbm { |x|
  parser = Yajl::Parser.new
  parser.on_parse_complete = lambda {|obj|} if times > 1
  x.report {
    puts "Yajl::Parser#parse"
    times.times {
      json.rewind
      parser.parse(json)
    }
  }
  x.report {
    puts "JSON.parse"
    times.times {
      json.rewind
      JSON.parse(json.read, :max_nesting => false)
    }
  }
}
json.close

# YAML section
filename = 'benchmark/subjects/ohai.yml'
yaml = File.new(filename, 'r')

puts "Starting benchmark parsing #{File.size(filename)} bytes of YAML data #{times} times\n\n"
Benchmark.bmbm { |x|
  x.report {
    puts "YAML.load_stream"
    times.times {
      yaml.rewind
      YAML.load(yaml)
    }
  }
}
yaml.close