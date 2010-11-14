require 'helper'

class TestBase < Test::Unit::TestCase
  
  def test_retry
    klass = Class.new(RetryingProxy::Base) do
      proxy_target{ |times| Foo.new(times) }
      retry_methods :foo, :times => 2
    end
    proxy = klass.new(2)
    proxy(proxy.target).foo.times(3)
    assert_equal "foo", proxy.foo
  end
  
end