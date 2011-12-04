module BestInPlace
  module DisplayMethods
    extend self

    @@table = Hash.new { |h,k| h[k] = Hash.new(&h.default_proc) }

    def lookup(klass, attr)
      foo = @@table[klass.to_s][attr.to_s]
      foo == {} ? nil : foo
    end

    def add(klass, attr, display_as)
      @@table[klass.to_s][attr.to_s] = display_as.to_sym
    end
  end
end
