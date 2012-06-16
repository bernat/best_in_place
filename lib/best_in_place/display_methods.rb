module BestInPlace
  module DisplayMethods
    extend self

    class Renderer < Struct.new(:opts)
      def render_json(object)
        case opts[:type]
        when :model
          {:display_as => object.send(opts[:method])}.to_json
        when :helper
          value = if opts[:helper_options]
                    BestInPlace::ViewHelpers.send(opts[:method], object.send(opts[:attr]), opts[:helper_options])
                  else
                    BestInPlace::ViewHelpers.send(opts[:method], object.send(opts[:attr]))
                  end
          {:display_as => value}.to_json
        when :proc
          {:display_as => opts[:proc].call(object.send(opts[:attr]))}.to_json
        else
          {}.to_json
        end
      end
    end

    @@table = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }

    def lookup(klass, attr)
      foo = @@table[klass.to_s][attr.to_s]
      foo == {} ? nil : foo
    end

    def add_model_method(klass, attr, display_as)
      @@table[klass.to_s][attr.to_s] = Renderer.new :method => display_as.to_sym, :type => :model
    end

    def add_helper_method(klass, attr, helper_method, helper_options = nil)
      @@table[klass.to_s][attr.to_s] = Renderer.new :method => helper_method.to_sym, :type => :helper, :attr => attr, :helper_options => helper_options
    end
    
    def add_helper_proc(klass, attr, helper_proc)
      @@table[klass.to_s][attr.to_s] = Renderer.new :type => :proc, :attr => attr, :proc => helper_proc
    end
  end
end
