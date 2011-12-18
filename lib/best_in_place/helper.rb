module BestInPlace
  module BestInPlaceHelpers

    def best_in_place(object, field, opts = {})
      opts[:type] ||= :input
      opts[:collection] ||= []
      field = field.to_s

      value = build_value_for(object, field, opts)

      collection = nil
      if opts[:type] == :select && !opts[:collection].blank?
        v = object.send(field)
        value = Hash[opts[:collection]][!!(v =~ /^[0-9]+$/) ? v.to_i : v]
        collection = opts[:collection].to_json
      end
      if opts[:type] == :checkbox
        fieldValue = !!object.send(field)
        if opts[:collection].blank? || opts[:collection].size != 2
          opts[:collection] = ["No", "Yes"]
        end
        value = fieldValue ? opts[:collection][1] : opts[:collection][0]
        collection = opts[:collection].to_json
      end
      out = "<span class='best_in_place'"
      out << " id='#{BestInPlace::Utils.build_best_in_place_id(object, field)}'"
      out << " data-url='#{opts[:path].blank? ? url_for(object) : url_for(opts[:path])}'"
      out << " data-object='#{object.class.to_s.gsub("::", "_").underscore}'"
      out << " data-collection='#{collection.gsub(/'/, "&#39;")}'" unless collection.blank?
      out << " data-attribute='#{field}'"
      out << " data-activator='#{opts[:activator]}'" unless opts[:activator].blank?
      out << " data-nil='#{opts[:nil]}'" unless opts[:nil].blank?
      out << " data-type='#{opts[:type]}'"
      out << " data-inner-class='#{opts[:inner_class]}'" if opts[:inner_class]
      out << " data-html-attrs='#{opts[:html_attrs].to_json}'" unless opts[:html_attrs].blank?
      out << " data-original-content='#{object.send(field)}'" if opts[:display_as]
      out << " data-custom-response-key='#{opts[:display_as]}'" if opts[:display_as]
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
      if opts[:display_as]
        BestInPlace::DisplayMethods.add(object.class.to_s, field, opts[:display_as])
        object.send(opts[:display_as]).to_s
      else
        object.send(field).to_s.presence || ""
      end
    end
  end
end

