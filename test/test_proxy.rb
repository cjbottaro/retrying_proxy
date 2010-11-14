require 'helper'

class TestProxy < Test::Unit::TestCase
  
  def test_proxy
    proxy = RetryingProxy::Proxy.new(Foo.new(1))
    proxy.proxy_method :foo
    proxy(proxy.target).foo.times(1)
    assert_raise(RuntimeError){ proxy.foo }
    proxy(proxy.target).foo.times(1)
    assert_equal "foo", proxy.foo
  end
  
  def test_retry
    proxy = RetryingProxy::Proxy.new(Foo.new(1))
    proxy.retry_method :foo
    proxy(proxy.target).foo.times(2)
    assert_equal "foo", proxy.foo
  end
  
  def test_retry_with_times
    proxy = RetryingProxy::Proxy.new(Foo.new(2))
    proxy.retry_method :foo, :times => 2
    proxy(proxy.target).foo.times(3)
    assert_equal "foo", proxy.foo
  end
  
  def test_retry_with_exceptions
    proxy = RetryingProxy::Proxy.new(Foo.new(1, ArgumentError))
    proxy.retry_method :foo, :exceptions => RuntimeError
    proxy(proxy.target).foo.times(1)
    assert_raise(ArgumentError){ proxy.foo }
    
    proxy = RetryingProxy::Proxy.new(Foo.new(1, ArgumentError))
    proxy.retry_method :foo, :exceptions => ArgumentError
    proxy(proxy.target).foo.times(2)
    assert_equal "foo", proxy.foo
  end
  
  def test_retry_with_delay
    proxy = RetryingProxy::Proxy.new(Foo.new(1))
    proxy.retry_method :foo, :delay => 0.23
    proxy(proxy.target).foo.times(2)
    mock(proxy).sleep(0.23)
    assert_equal "foo", proxy.foo
  end
  
  def test_retry_with_predicate
    proxy = RetryingProxy::Proxy.new(Foo.new)
    proxy.retry_method :bar, :baz, :predicate => Proc.new{ |value| value =~ /r$/ }
    proxy(proxy.target).bar.times(2)
    assert_equal "bar", proxy.bar
    proxy(proxy.target).baz.times(1)
    assert_equal "baz", proxy.baz
  end
  
  def test_retries_resets_between_method_calls
    proxy = RetryingProxy::Proxy.new(Foo.new(1))
    proxy.retry_method :bar, :predicate => Proc.new{ |value| value =~ /^b/ }
    proxy(proxy.target).bar.times(2)
    assert_equal "bar", proxy.bar
    proxy(proxy.target).bar.times(2)
    assert_equal "bar", proxy.bar
  end
  
  def test_method_missing
    proxy = RetryingProxy::Proxy.new(Foo.new(2))
    proxy.retry_method :fu, :times => 2
    proxy(proxy.target).fu.times(3)
    assert_equal "foo", proxy.fu
  end
  
end