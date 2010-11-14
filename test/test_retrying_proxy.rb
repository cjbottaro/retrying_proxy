require 'helper'

class TestRetryingProxy < Test::Unit::TestCase
  
  def test_retry
    klass = Class.new do
      include Foo::InstanceMethods
      include RetryingProxy
      retry_method :foo, :times => 2
    end
    object = klass.new(2)
    proxy(object).foo_without_retrying_proxy.times(3)
    assert_equal "foo", object.foo
  end
  
  def test_punctuation
    klass = Class.new do
      include Foo::InstanceMethods
      include RetryingProxy
      alias_method :foo!, :foo
      retry_method :foo!, :times => 3
    end
    assert klass.method_defined?(:foo!)
    assert klass.method_defined?(:foo_with_retrying_proxy!)
    assert klass.method_defined?(:foo_without_retrying_proxy!)
    object = klass.new(3)
    proxy(object).foo_without_retrying_proxy!.times(4)
    assert_equal "foo", object.foo!
  end
  
end
