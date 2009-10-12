module DNZ
  # Subclass of Array that allows retrieval by facet name
  class FacetArray < Array
    def names
      self.collect(&:name).uniq
    end
    
    def [](value)
      if value.is_a?(String) || value.is_a?(Symbol)
        self.detect{|f| f.name == value.to_s }
      else
        super
      end
    end
  end
end