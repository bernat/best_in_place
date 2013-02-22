module BestInPlace
  module ControllerExtensions
    def respond_with_bip(obj, options={})
      obj.changed? ? respond_bip_error(obj) : respond_bip_ok(obj, options)
    end

  private
    def respond_bip_ok(obj, options)
      if options[:class_name]
        klass = options[:class_name]
      elsif obj.respond_to?(:id)
        klass = "#{obj.class}_#{obj.id}"
      else
        klass = obj.class.to_s
      end
      param_key = options[:param_key] || BestInPlace::Utils.object_to_key(obj)
      updating_attr = params[param_key].keys.first

      if renderer = BestInPlace::DisplayMethods.lookup(klass, updating_attr)
        render :json => renderer.render_json(obj)
      else
        head :no_content
      end
    end

    def respond_bip_error(obj)
      render :json => obj.errors.full_messages, :status => :unprocessable_entity
    end
  end
end
