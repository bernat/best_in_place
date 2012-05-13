module BestInPlace
  module ControllerExtensions
    def respond_with_bip(obj)
      obj.changed? ? respond_bip_error(obj) : respond_bip_ok(obj)
    end

  private
    def respond_bip_ok(obj)
      klass = obj.class.to_s
      param_key = BestInPlace::Utils.object_to_key(obj)
      updating_attr = params[param_key].keys.first

      if renderer = BestInPlace::DisplayMethods.lookup(klass, updating_attr)
        render :json => renderer.render_json(obj)
      else
        head :ok
      end
    end

    def respond_bip_error(obj)
      render :json => obj.errors.full_messages, :status => :unprocessable_entity
    end
  end
end
