module RetryingProxy
  class Proxy
    attr_accessor :target
    attr_reader :settings
    
    DEFAULTS = { :times       => 1,
                 :exceptions  => Exception,
                 :delay       => nil,
                 :predicate   => nil }
    
    def initialize(target = nil)
      @target = target
      @settings = {}
    end
    
    def retry_methods(*args)
      # Handle options.
      options = args.last.kind_of?(Hash) ? args.pop : {}
      options = DEFAULTS.merge(options)
      
      # Normalize some options.
      options[:exceptions] = [options[:exceptions]].flatten
      
      # Normalize the method names.
      method_names = args.collect{ |arg| arg.to_sym }
      
      # Store the settings
      method_names.each{ |method_name| settings[method_name] = options }
      
      method_names.each do |method_name|
        singleton_class.class_eval do
          define_method(method_name) do |*args, &block|
            call(method_name, args, &block)
          end
        end
      end
      
      method_names
    end
    
    alias_method :retry_method, :retry_methods
    
    # List of methods to pass through unaltered.
    #   proxy_methods :foo, :bar, :baz
    def proxy_methods(*args)
      retry_methods(*(args + [:times => 0])) # It has to be this way for Ruby 1.8
    end
    
    alias_method :proxy_method, :proxy_methods
    
    # Direcly call a method on the target without any wrapping or anything.
    def raw_call(method_name, *args, &block)
      if target.respond_to?(method_name)
        target.send(method_name, *args, &block)
      else
        target.method_missing(method_name, *args, &block)
      end
    end
    
    # Call a method on the target wrapped with the retry logic.
    def call(method_name, args, options = {}, &block)
      
      # This is tricky.  In the case of including RetryingProxy, we have to do all that alias
      # method chain stuff, so the method_name argument will have _without_retrying_proxy
      # appended to it.  options[:method_name] will provide the unmangled name in that case
      # so we can look up the settings properly.
      settings = self.settings[options[:method_name] || method_name]
      
      # Don't increment our retries counter if we're in recursion or we'll do infinite retries.
      @retries = 0 unless options[:in_recursion]
      
      begin
        value = raw_call(method_name, *args, &block)
      rescue *settings[:exceptions] => e
        should_retry?(settings) ? retry : raise
      end
      
      if settings[:predicate] and should_retry?(settings){ settings[:predicate].call(value) }
        value = call(method_name, args, options.merge(:in_recursion => true), &block)
      end
      
      value
    end
    
    # Returns true if we should retry calling the method.  +settings+ should be for the method
    # being called.  If a block an optional predicate to determine if we should retry.
    def should_retry?(settings, &block)
      return false unless @retries < settings[:times]
      return false if block_given? and not block.call
      sleep(settings[:delay]) if settings[:delay]
      @retries += 1
      true
    end
    
  end
end