module BestInPlace
  module Utils #:nodoc:
    module_function
    def build_best_in_place_id(object, field, appendix = nil)
      case object
        when Symbol, String
          "best_in_place_#{object}_#{field}"
        else
          id = "best_in_place_#{object_to_key(object)}"
          id << "_#{object.id}" if object.persisted?
          id << "_#{field}"
          id << "_#{appendix}" if !appendix.nil?
          id
      end
    end

    def object_to_key(object)
      model_name_from_record_or_class(object).param_key
    end

    def convert_to_model(object)
      object.respond_to?(:to_model) ? object.to_model : object
    end

    def model_name_from_record_or_class(record_or_class)
      (record_or_class.is_a?(Class) ? record_or_class : convert_to_model(record_or_class).class).model_name
    end

  end
end
