require 'helper'

class TestInheritance < Test::Unit::TestCase

  def test_inheritance
    base = Class.new do
      include RetryingProxy
      def foo
      end
      retry_method :foo
    end
    derived = Class.new(base)
    assert derived.retrying_proxy.settings.has_key?(:foo)
  end

end
