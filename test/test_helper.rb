$:.unshift File.join(File.dirname(__FILE__), "../lib")
ENV["RACK_ENV"] = "test"

FIXTURES = File.join(File.dirname(__FILE__), "fixtures")

# require 'mocha'
require 'test/spec'

require 'fluffy_barbarian'
