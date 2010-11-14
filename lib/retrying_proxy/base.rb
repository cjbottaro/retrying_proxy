require "retrying_proxy/proxy"

module RetryingProxy
  class Base
    
    class << self
      
      def proxy
        @proxy ||= Proxy.new
      end
      
      def proxy_target(&block)
        if block_given?
          @target = block
        else
          @target
        end
      end
      
      def retry_methods(*args)
        proxy.retry_methods(*args).each do |method_name|
          define_method(method_name) do |*args, &block|
            call(method_name, *args, &block)
          end
        end
      end
      
      alias_method :retry_method, :retry_methods
      
      def proxy_methods(*args)
        retry_methods(*(args + [:times => 0])) # It has to be this way for Ruby 1.8
      end
      
      alias_method :proxy_method, :proxy_methods
      
    end
    
    def initialize(*args, &block)
      proxy.target = self.class.proxy_target.call(*args, &block)
    end
    
    def target
      proxy.target
    end
    
    def proxy
      self.class.proxy
    end
    
    def call(method_name, *args, &block)
      proxy.send(method_name, *args, &block)
    end
    
  end
end