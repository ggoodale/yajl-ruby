# encoding: UTF-8
require 'rubygems'
require 'benchmark'
begin
  require 'yajl_ext'
rescue LoadError
  require 'yajl/ffi'
end
require 'stringio'
require 'json'

times = ARGV[0] ? ARGV[0].to_i : 1000
filename = 'benchmark/subjects/ohai.json'
json = File.new(filename, 'r')
hash = Yajl::Parser.new.parse(json)
json.close

puts "Starting benchmark encoding #{filename} #{times} times\n\n"
Benchmark.bmbm { |x|
  encoder = Yajl::Encoder.new
  x.report {
    puts "Yajl::Encoder#encode"
    times.times {
      encoder.encode(hash, StringIO.new)
    }
  }
  x.report {
    puts "JSON's #to_json"
    times.times {
      JSON.generate(hash)
    }
  }
  x.report {
    puts "Marshal.dump"
    times.times {
      Marshal.dump(hash)
    }
  }
}
