require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'retrying_proxy'
require "rr"

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end

class Foo
  
  module InstanceMethods
    
    # Foo must be called +times+ times before not raising an exception.
    def initialize(times = nil, exception = RuntimeError)
      @times = times
      @exception = exception
      @count = 0
    end
    
    def foo
      if @times.nil? or @count < @times
        @count += 1
        raise @exception, "oops"
      end
      @count = 0
      "foo"
    end
  
    def bar
      "bar"
    end
  
    def baz
      "baz"
    end
    
  end
  
  include InstanceMethods
  
end