require 'dnz/attributes'

module DNZ
  # A facet retrieved from DigitalNZ search results. The facet has a name and an array of
  # FacetValue objects.
  class Facet
    # The facet name
    attr_reader :name
      
    # The search that orginally ran to produce this facet
    attr_reader :search
    
    include Enumerable
    
    # Find a facet and return it. This is a convienence method for running
    # Client.search('search', :facets => facet).facets[facet].
    #
    # * <tt>facet</tt> - The name of the facet.
    # * <tt>search_text</tt> - Optional search text. Defaults to everything (*:*).
    # * <tt>num_results</tt> - Optional maximum number of facet values to return in the
    # facet. This defaults to -1 which means no limit.
    def self.find(facet, search_text = '*:*', num_results = -1)      
      options = {:facets => facet, :facet_num_results => num_results, :num_results => 0}
      Client.search(search_text, options).facets[facet]
    end
    
    # Find related facet values. This is a convienence method for running
    # Client.search('parent_facet:value', :facets => facet).facets[facet]. It will
    # return the facet and facet values for results scoped to another facet.
    #
    # * <tt>facet</tt> - The name of the facet.
    # * <tt>parent_facet</tt> - The name of the facet to scope results to.
    # * <tt>value</tt> - The facet value to scope the results to.
    # * <tt>search_text</tt> - Optional search text. Defaults to everything (*:*).
    # * <tt>num_results</tt> - Optional maximum number of facet values to return in the
    # facet. This defaults to -1 which means no limit.
    def self.find_related(facet, parent_facet, value, search_text = '*:*', num_results = -1)
      search_text = [search_text, '%s:"%s"' % [parent_facet, value]].join(' AND ')
      self.find(facet, search_text, num_results)
    end

    def initialize(client, search, doc)
      @name = doc.xpath('facet-field').text
      @values = []
      @search = search

      doc.xpath('values').first.children.each do |value_doc|
        value = DNZ::FacetValue.new(client, self, value_doc)
        @values << value if value.valid?
      end
    end
    
    # An array of FacetValue objects
    def values
      @values
    end

    # Retrieve a FacetValue by name
    def [](index)
      @values.detect{|value| value.name == index }
    end
    
    # Enumerate the FacetValue objects
    def each
      @values.each do |value|
        yield value
      end
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