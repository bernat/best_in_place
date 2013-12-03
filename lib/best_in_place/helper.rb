module BestInPlace
  module BestInPlaceHelpers

    def best_in_place(object, field, opts = {})
      if opts[:display_as] && opts[:display_with]
        raise ArgumentError, "Can't use both 'display_as' and 'display_with' options at the same time"
      end

      if opts[:display_with] && !opts[:display_with].is_a?(Proc) && !ViewHelpers.respond_to?(opts[:display_with])
        raise ArgumentError, "Can't find helper #{opts[:display_with]}"
      end

      real_object = real_object_for object
      opts[:type] ||= :input
      opts[:collection] ||= []
      field = field.to_s

      display_value = build_value_for(real_object, field, opts)

      collection = nil
      value = nil
      if opts[:type] == :select && !opts[:collection].blank?
        value = real_object.send(field)
        display_value = Hash[opts[:collection]].stringify_keys[value.to_s]
        collection = opts[:collection].to_json
      end
      if opts[:type] == :checkbox
        value = !!real_object.send(field)
        if !opts[:collection].blank? && opts[:collection][0] == :actual_checkbox
          opts[:collection] = ['<input type=checkbox></input>', '<input type=checkbox checked></input>']
          opts[:sanitize] = false
        elsif opts[:collection].blank? || opts[:collection].size != 2
          opts[:collection] = ["No", "Yes"]
        end
        display_value = value ? opts[:collection][1] : opts[:collection][0]
        collection = opts[:collection].to_json
      end
      classes = ["best_in_place"]
      unless opts[:classes].nil?
        # the next three lines enable this opt to handle both a stings and a arrays
        classes << opts[:classes]
        classes.flatten!
      end

      out = "<span class='#{classes.join(" ")}'"
      out << " id='#{BestInPlace::Utils.build_best_in_place_id(real_object, field)}'"
      out << " data-url='#{opts[:path].blank? ? url_for(object) : url_for(opts[:path])}'"
      out << " data-object='#{opts[:object_name] || BestInPlace::Utils.object_to_key(real_object)}'"
      out << " data-collection='#{attribute_escape(collection)}'" unless collection.blank?
      out << " data-attribute='#{field}'"
      out << " data-activator='#{opts[:activator]}'" unless opts[:activator].blank?
      out << " data-ok-button='#{opts[:ok_button]}'" unless opts[:ok_button].blank?
      out << " data-ok-button-class='#{opts[:ok_button_class]}'" unless opts[:ok_button_class].blank?
      out << " data-cancel-button='#{opts[:cancel_button]}'" unless opts[:cancel_button].blank?
      out << " data-cancel-button-class='#{opts[:cancel_button_class]}'" unless opts[:cancel_button_class].blank?
      out << " data-nil='#{attribute_escape(opts[:nil])}'" unless opts[:nil].blank?
      out << " data-use-confirm='#{opts[:use_confirm]}'" unless opts[:use_confirm].nil?
      out << " data-type='#{opts[:type]}'"
      out << " data-inner-class='#{opts[:inner_class]}'" if opts[:inner_class]
      out << " data-html-attrs='#{opts[:html_attrs].to_json}'" unless opts[:html_attrs].blank?
      if opts[:display_content]
        out << " data-original-content='#{opts[:display_content]}'"
      elsif opts[:display_as] || opts[:display_with]
        out << " data-original-content='#{attribute_escape(real_object.send(field))}'"
      end
      out << " data-mask='#{opts[:mask]}'" if opts[:mask]
      out << " data-value='#{attribute_escape(value)}'" if value

      if opts[:data] && opts[:data].is_a?(Hash)
        opts[:data].each do |k, v|
          if !v.is_a?(String) && !v.is_a?(Symbol)
            v = v.to_json
          end
          out << %( data-#{k.to_s.dasherize}="#{v}")
        end
      end
      if !opts[:sanitize].nil? && !opts[:sanitize]
        out << " data-sanitize='false'>"
        out << display_value.to_s
      else
        out << ">#{h(display_value.to_s)}"
      end
      out << "</span>"
      raw out
    end

    def best_in_place_if(condition, object, field, opts={})
      if condition
        best_in_place(object, field, opts)
      else
        build_value_for real_object_for(object), field, opts
      end
    end

  private
    def build_value_for(object, field, opts)
      return "" if object.send(field).blank?

      klass = if object.respond_to?(:id)
        "#{object.class}_#{object.id}"
      else
        object.class.to_s
      end

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
          BestInPlace::ViewHelpers.send(opts[:display_with], object.send(field))
        end

      else
        object.send(field).to_s
      end
    end

    def attribute_escape(data)
      return unless data

      data.to_s.
        gsub("&", "&amp;").
        gsub("'", "&apos;").
        gsub(/\r?\n/, "&#10;")
    end

    def real_object_for(object)
      (object.is_a?(Array) && object.last.class.respond_to?(:model_name)) ? object.last : object
    end
  end
end

