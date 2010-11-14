require 'helper'

# This is just to reach 100% coverage.
class TestCoverage < Test::Unit::TestCase
  
  def test_alias_method_chain
    klass = Class.new do
      def foo; end
      def bar; end
      def foo_with_nothing; end
      def bar_with_nothing; end
      protected :foo
      private :bar
      alias_method_chain :foo, :nothing
      alias_method_chain :bar, :nothing
    end
    assert klass.protected_method_defined?(:foo)
    assert klass.private_method_defined?(:bar)
  end
  
end