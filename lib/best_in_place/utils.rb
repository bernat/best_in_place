module BestInPlace
  class Utils

    def self.build_best_in_place_id(object, field)
      if object.is_a?(Symbol) || object.is_a?(String)
        return "best_in_place_#{object}_#{field}"
      end

      id = "best_in_place_#{object.class.to_s.demodulize.underscore}"
      id << "_#{object.id}" if object.class.ancestors.include?(ActiveModel::Serializers::JSON)
      id << "_#{field}"
      id
    end
  end
end
