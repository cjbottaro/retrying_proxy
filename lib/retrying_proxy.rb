require "retrying_proxy/active_support"
require "retrying_proxy/base"
require "retrying_proxy/proxy"

module RetryingProxy
  
  VERSION = File.read(File.dirname(__FILE__)+"/../VERSION").freeze
  
  def self.included(mod)
    mod.send(:extend, ClassMethods)
    mod.send(:include, InstanceMethods)
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
