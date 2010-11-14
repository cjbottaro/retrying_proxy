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
  
  def test_proxy
    klass = Class.new(RetryingProxy::Base) do
      proxy_target{ |times| Foo.new(times) }
      proxy_method :foo
    end
    proxy = klass.new(1)
    proxy(proxy.target).foo.times(1)
    assert_raise(RuntimeError){ proxy.foo }
  end
  
end