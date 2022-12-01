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
        collection = best_in_place_default_collection if collection.blank?
        collection = best_in_place_collection_builder(type, collection)
        display_value = collection.flat_map{|a| a[0].to_s == value ? a[1] : nil }.compact[0]
        collection = collection.to_json
        options[:data]['bip-collection'] = html_escape(collection)
      end

      options[:class] = ['best_in_place'] + Array(opts[:class] || opts[:classes])
      options[:id] = opts[:id] || BestInPlace::Utils.build_best_in_place_id(real_object, field)

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

      options[:data]['bip-skip-blur'] = opts.has_key?(:skip_blur) ? opts[:skip_blur].presence : BestInPlace.skip_blur

      options[:data]['bip-url'] = url_for(opts[:url] || object)

      if real_object.respond_to?(:new_record?) and real_object.new_record?
        options[:data]['bip-new-object'] = true
        # collect name => value map of unsaved attributes to be serialized
        options[:data]['bip-extra-payload'] = Hash[real_object.changes.map { |k,v| [k, v[1]] }]
      end

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
                    :as, :param, :container]
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

    def best_in_place_deprecated_options(opts)
      deprecations = [
          {from: :path, to: :url},
          {from: :object_name, to: :param},
          {from: :type, to: :as},
          {from: :classes, to: :class},
          {from: :nil, to: :place_holder},
          {from: :use_confirm, to: :confirm},
          {from: :sanitize, to: :raw}
      ]

      deprecations.each do |deprecation|
        if deprecated_option = opts.delete(deprecation[:from])
          opts[deprecation[:from]] = deprecated_option
          ActiveSupport::Deprecation.warn("[Best_in_place] :#{deprecation[:from]} is deprecated in favor of :#{deprecation[:to]} ")
        end
      end
    end

    def best_in_place_collection_builder(type, collection)
      return Array(collection) if collection.is_a?(Hash)

      if type == :checkbox
        best_in_place_collection_checkbox(collection)
      else # :select
        best_in_place_collection_select(collection)
      end
    end

    def best_in_place_collection_checkbox(collection)
      if collection.length == 2
        [['false', collection[0]], ['true', collection[1]]]
      else
        fail ArgumentError, '[Best_in_place] :collection array should have 2 values'
      end
    end

    def best_in_place_collection_select(collection)
      return Array(collection) if collection[0].is_a?(Array) || collection[0].length == 2

      collection.each_with_index.map { |a, i| [i+1, a] }
    end

    def best_in_place_default_collection
      {'true' => t(:'best_in_place.yes', default: 'Yes'),
       'false' => t(:'best_in_place.no', default: 'No')}
    end
  end
end
