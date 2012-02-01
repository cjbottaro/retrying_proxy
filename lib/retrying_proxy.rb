require "retrying_proxy/active_support"
require "retrying_proxy/base"
require "retrying_proxy/proxy"

module RetryingProxy
  
  def self.included(mod)
    mod.send(:extend, ClassMethods)
    mod.send(:include, InstanceMethods)

    # Make sure inherited classes get the retrying_proxy object copied over.
    mod.class_eval do
      class << self
        def inherited_with_retrying_proxy(klass)
          inherited_without_retrying_proxy(klass)
          klass.instance_variable_set(:@retrying_proxy, retrying_proxy.deep_clone)
        end
        alias_method_chain :inherited, :retrying_proxy
      end
    end

  end
  
  module ClassMethods
    
    def retrying_proxy
      @retrying_proxy ||= Proxy.new
    end
    
    def retry_methods(*args)
      retrying_proxy.retry_methods(*args).each do |method_name|
        alias_method_chain(method_name, :retrying_proxy) do |base_method_name, punc|
          define_method("#{base_method_name}_with_retrying_proxy#{punc}") do |*args, &block|
            retrying_proxy.call("#{base_method_name}_without_retrying_proxy#{punc}", args, :method_name => method_name, &block)
          end
        end
      end
    end
    
    alias_method :retry_method, :retry_methods
    
  end
  
  module InstanceMethods
    
    def retrying_proxy
      self.class.retrying_proxy.tap{ |proxy| proxy.target = self }
    end
    
  end
  
end
