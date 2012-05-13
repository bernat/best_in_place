module BestInPlace
  module BestInPlaceHelpers

    def best_in_place(object, field, opts = {})
      if opts[:display_as] && opts[:display_with]
        raise ArgumentError, "Can't use both 'display_as' and 'display_with' options at the same time"
      end

      if opts[:display_with] && !opts[:display_with].is_a?(Proc) && !ViewHelpers.respond_to?(opts[:display_with])
        raise ArgumentError, "Can't find helper #{opts[:display_with]}"
      end

      real_object = (object.is_a?(Array) && object.last.class.respond_to?(:model_name)) ? object.last : object
      opts[:type] ||= :input
      opts[:collection] ||= []
      field = field.to_s

      value = build_value_for(real_object, field, opts)

      collection = nil
      if opts[:type] == :select && !opts[:collection].blank?
        v = real_object.send(field)
        value = Hash[opts[:collection]][!!(v =~ /^[0-9]+$/) ? v.to_i : v]
        collection = opts[:collection].to_json
      end
      if opts[:type] == :checkbox
        fieldValue = !!real_object.send(field)
        if opts[:collection].blank? || opts[:collection].size != 2
          opts[:collection] = ["No", "Yes"]
        end
        value = fieldValue ? opts[:collection][1] : opts[:collection][0]
        collection = opts[:collection].to_json
      end
      out = "<span class='best_in_place'"
      out << " id='#{BestInPlace::Utils.build_best_in_place_id(real_object, field)}'"
      out << " data-url='#{opts[:path].blank? ? url_for(object) : url_for(opts[:path])}'"
      out << " data-object='#{opts[:object_name] || BestInPlace::Utils.object_to_key(real_object)}'"
      out << " data-collection='#{attribute_escape(collection)}'" unless collection.blank?
      out << " data-attribute='#{field}'"
      out << " data-activator='#{opts[:activator]}'" unless opts[:activator].blank?
      out << " data-ok-button='#{opts[:ok_button]}'" unless opts[:ok_button].blank?
      out << " data-cancel-button='#{opts[:cancel_button]}'" unless opts[:cancel_button].blank?
      out << " data-nil='#{opts[:nil]}'" unless opts[:nil].blank?
      out << " data-type='#{opts[:type]}'"
      out << " data-inner-class='#{opts[:inner_class]}'" if opts[:inner_class]
      out << " data-html-attrs='#{opts[:html_attrs].to_json}'" unless opts[:html_attrs].blank?
      out << " data-original-content='#{attribute_escape(real_object.send(field))}'" if opts[:display_as] || opts[:display_with]
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
        out << sanitize(value, :tags => %w(b i u s a strong em p h1 h2 h3 h4 h5 ul li ol hr pre span img br), :attributes => %w(id class href))
      else
        out << ">#{sanitize(value, :tags => nil, :attributes => nil)}"
      end
      out << "</span>"
      raw out
    end

    def best_in_place_if(condition, object, field, opts={})
      if condition
        best_in_place(object, field, opts)
      else
        build_value_for object, field, opts
      end
    end

  private
    def build_value_for(object, field, opts)
      return "" if object.send(field).blank?

      if opts[:display_as]
        BestInPlace::DisplayMethods.add_model_method(object.class.to_s, field, opts[:display_as])
        object.send(opts[:display_as]).to_s

      elsif opts[:display_with].try(:is_a?, Proc)
        opts[:display_with].call(object.send(field))

      elsif opts[:display_with]
        BestInPlace::DisplayMethods.add_helper_method(object.class.to_s, field, opts[:display_with], opts[:helper_options])
        if opts[:helper_options]
          BestInPlace::ViewHelpers.send(opts[:display_with], object.send(field), opts[:helper_options])
        else
          BestInPlace::ViewHelpers.send(opts[:display_with], object.send(field))
        end

      else
        object.send(field).to_s.presence || ""
      end
    end

    def attribute_escape(data)
      return unless data

      data.to_s.
        gsub("&", "&amp;").
        gsub("'", "&apos;").
        gsub("\n", "&#10;")
    end
  end
end

