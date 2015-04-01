module BestInPlace
  module Helper
    def best_in_place(object, field, opts = {})

      best_in_place_assert_arguments(opts)
      type = opts[:as] || :input
      field = field.to_s

      options = {}
      options[:data] = HashWithIndifferentAccess.new(opts[:data])
      options[:data]['bip-type'] = type
      options[:data]['bip-attribute'] = field

      real_object = best_in_place_real_object_for object

      display_value = best_in_place_build_value_for(real_object, field, opts)

      value = real_object.send(field)

      if opts[:collection] or type == :checkbox
        collection = opts[:collection]
        value = value.to_s
        collection = if collection.blank?
          best_in_place_default_collection
        else
          best_in_place_collection_builder(type, collection)
        end
        display_value = collection.flat_map{|a| a[0].to_s == value ? a[1] : nil }.compact[0]
        collection = collection.to_json
        options[:data]['bip-collection'] = html_escape(collection)
      end

      options[:class] = ['best_in_place'] + Array(opts[:class] || opts[:classes])
      options[:data]['id_appendix'] = opts[:id_appendix].presence
      options[:id] = opts[:id] || BestInPlace::Utils.build_best_in_place_id(real_object, field, options[:data]['id_appendix'])

      pass_through_html_options(opts, options)

      options[:data]['bip-activator'] = opts[:activator].presence

      options[:data]['bip-html-attrs'] = opts[:html_attrs].to_json unless opts[:html_attrs].blank?
      options[:data]['bip-inner-class'] = opts[:inner_class].presence

      options[:data]['bip-placeholder'] = html_escape(opts[:place_holder]).presence

      options[:data]['bip-object'] = opts[:param] || BestInPlace::Utils.object_to_key(real_object)
      options[:data]['bip-ok-button'] = opts[:ok_button].presence
      options[:data]['bip-ok-button-class'] = opts[:ok_button_class].presence
      options[:data]['bip-cancel-button'] = opts[:cancel_button].presence
      options[:data]['bip-cancel-button-class'] = opts[:cancel_button_class].presence
      options[:data]['bip-original-content'] = html_escape(opts[:value] || value).presence

      options[:data]['bip-skip-blur'] = opts[:skip_blur].presence

      options[:data]['bip-url'] = url_for(opts[:url] || object)

      options[:data]['bip-confirm'] = opts[:confirm].presence
      options[:data]['bip-value'] = html_escape(value).presence

      if opts[:raw]
        options[:data]['bip-raw'] = 'true'
      end

      # delete nil keys only
      options[:data].delete_if { |_, v| v.nil? }
      container = opts[:container] || BestInPlace.container
      content_tag(container, display_value, options, opts[:raw].blank?)
    end

    def best_in_place_if(condition, object, field, opts = {})
      if condition
        best_in_place(object, field, opts)
      else
        best_in_place_build_value_for best_in_place_real_object_for(object), field, opts
      end
    end

    def best_in_place_unless(condition, object, field, opts = {})
      best_in_place_if(!condition, object, field, opts)
    end

    private

    def pass_through_html_options(opts, options)
      known_keys = [:id, :type, :nil, :classes, :collection, :data,
                    :activator, :cancel_button, :cancel_button_class, :html_attrs, :inner_class, :nil,
                    :object_name, :ok_button, :ok_button_class, :display_as, :display_with, :path, :value,
                    :use_confirm, :confirm, :sanitize, :raw, :helper_options, :url, :place_holder, :class,
                    :as, :param, :container, :id_appendix]
      uknown_keys = opts.keys - known_keys
      uknown_keys.each { |key| options[key] = opts[key] }
    end

    def best_in_place_build_value_for(object, field, opts)
      klass = object.class
      if opts[:display_as]
        BestInPlace::DisplayMethods.add_model_method(klass, field, opts[:display_as])
        object.send(opts[:display_as]).to_s

      elsif opts[:display_with].try(:is_a?, Proc)
        BestInPlace::DisplayMethods.add_helper_proc(klass, field, opts[:display_with])
        opts[:display_with].call(object.send(field))

      elsif opts[:display_with]
        BestInPlace::DisplayMethods.add_helper_method(klass, field, opts[:display_with], opts[:helper_options])
        if opts[:helper_options]
          BestInPlace::ViewHelpers.send(opts[:display_with], object.send(field), opts[:helper_options])
        else
          field_value = object.send(field)

          if field_value.blank?
            ''
          else
            BestInPlace::ViewHelpers.send(opts[:display_with], field_value)
          end
        end

      else
        object.send(field).to_s
      end
    end

    def best_in_place_real_object_for(object)
      (object.is_a?(Array) && object.last.class.respond_to?(:model_name)) ? object.last : object
    end

    def best_in_place_assert_arguments(args)
      best_in_place_deprecated_options(args)

      if args[:display_as] && args[:display_with]
        fail ArgumentError, 'Can`t use both `display_as`` and `display_with` options at the same time'
      end

      if args[:display_with] && !args[:display_with].is_a?(Proc) && !ViewHelpers.respond_to?(args[:display_with])
        fail ArgumentError, "Can't find helper #{args[:display_with]}"
      end
    end

    def best_in_place_deprecated_options(args)
      if deprecated_option = args.delete(:path)
        args[:url] = deprecated_option
        ActiveSupport::Deprecation.warn('[Best_in_place] :path is deprecated in favor of :url ')
      end

      if deprecated_option = args.delete(:object_name)
        args[:param] = deprecated_option
        ActiveSupport::Deprecation.warn('[Best_in_place] :object_name is deprecated in favor of :param ')
      end

      if deprecated_option = args.delete(:type)
        args[:as] = deprecated_option
        ActiveSupport::Deprecation.warn('[Best_in_place] :type is deprecated in favor of :as ')
      end

      if deprecated_option = args.delete(:classes)
        args[:class] = deprecated_option
        ActiveSupport::Deprecation.warn('[Best_in_place] :classes is deprecated in favor of :class ')
      end

      if deprecated_option = args.delete(:nil)
        args[:place_holder] = deprecated_option
        ActiveSupport::Deprecation.warn('[Best_in_place] :nil is deprecated in favor of :place_holder ')
      end

      if deprecated_option = args.delete(:use_confirm)
        args[:confirm] = deprecated_option
        ActiveSupport::Deprecation.warn('[Best_in_place] :use_confirm is deprecated in favor of :confirm ')
      end

      if deprecated_option = args.delete(:sanitize)
        args[:raw] = !deprecated_option
        ActiveSupport::Deprecation.warn('[Best_in_place] :sanitize is deprecated in favor of :raw ')
      end
    end

    def best_in_place_collection_builder(type, collection)
      collection = case collection
        when Array
          if type == :checkbox
            if collection.length == 2
              [['false', collection[0]], ['true', collection[1]]]
            else
              fail ArgumentError, '[Best_in_place] :collection array should have 2 values'
            end
          else # :select
            case collection[0]
              when Array
                collection
              else
                if collection[0].length == 2
                  collection.to_a
                else
                  collection.each_with_index.map{|a,i| [i+1,a]}
                end
            end
          end
        else
          collection.to_a
      end
      collection
    end

    def best_in_place_default_collection
      {'true' => t(:'best_in_place.yes', default: 'Yes'),
       'false' => t(:'best_in_place.no', default: 'No')}
    end
  end
end
