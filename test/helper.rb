require 'rubygems'
require 'test/unit'

require "retrying_proxy"
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
    
    def method_missing(method_name, *args, &block)
      if method_name == :fu
        foo
      else
        super
      end
    end
    
  end
  
  include InstanceMethods
  
end
