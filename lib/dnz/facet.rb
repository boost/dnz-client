require 'dnz/attributes'

module DNZ
  class Facet
    attr_reader :name
    attr_reader :values
    attr_reader :search
    
    include Enumerable

    def initialize(client, search, doc)
      @name = doc.xpath('facet-field').text
      @values = {}
      @search = search

      doc.xpath('values').first.children.each do |value_doc|
        value = DNZ::FacetValue.new(client, self, value_doc)
        @values[value.name] = value if value.valid?
      end
    end
    
    def values
      @values.values
    end
    
    def [](index)
      @values[index]
    end
    
    def each
      @values.each {|key, value| yield value }
    end
    
    def to_s
      values.join(', ')
    end
    
    def inspect
      '[ %s ]' % values.collect(&:inspect).join(', ')
    end
  end

  class FacetValue
    attr_reader :name, :count

    def initialize(client, facet, doc)
      @client = client
      @facet = facet
      @search_text = facet.search.text
      @name = doc.xpath('name').text
      @count = doc.xpath('num-results').text.to_i
    end

    def valid?
      !self.name.blank?
    end

    def search(text = @search_text, options = {})
      @client.search('%s:%s %s' % [@facet.name, self.name, text], options)
    end

    def inspect
      {:name => self.name, :count => self.count}.inspect
    end

    def to_s
      '%s => %d' % [self.name, self.count]
    end
  end
end