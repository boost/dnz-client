require 'nokogiri'
require 'dnz/result'
require 'dnz/facet_array'
require 'dnz/facet'
require 'dnz/memoizable'

# Load will_paginate if it's available
# to provide pagination
begin
  gem 'mislav-will_paginate' rescue nil
  require 'will_paginate/collection' rescue nil
rescue LoadError => e
end

module DNZ
  class Results
    extend DNZ::Memoizable
    
    attr_reader :result_count
    
    # An array of facets.
    #
    # === Example
    #   search = client.search('text', :facets => 'category')
    #   categories = search.facets['category']
    #   categories.each do |category|
    #     puts '%d results in category %s' % [category.count, category.name]
    #   end
    attr_reader :facets
    
    # An array of results. If the mislav-will_paginate gem is installed this will return a paginated array.
    attr_reader :results
    
    def initialize(xml, search)
      reset

      @xml = xml
      @search = search

      # Parse the results
      parse_attributes
      parse_facets
      parse_results
      paginate_results if defined? WillPaginate::Collection
    end    

    # The current page of results, based on the number of requested results and the start value
    # (see <tt>Client.search</tt>).
    def page
      (((@start || 0) / num_results_requested) + 1) rescue 1
    end
    
    # The number of pages available for the current search.
    def pages
      num_results_requested < result_count ? (result_count.to_f / num_results_requested).ceil : 1
    end
    
    def per_page
      num_results_requested < 1 ? 1 : num_results_requested
    end

    # The number of results requested via the :num_results option (see <tt>Client.search</tt>).
    def num_results_requested
      @num_results_requested || 20
    end    

    private
    
    # Return a Nokogiri document for the XML
    def doc
      @doc ||= Nokogiri::XML(@xml)
    end

    # Reset important instance variables
    def reset
      @doc = nil
      @results = nil
      @facets = nil
    end

    # Replace the results array with a paginated array
    def paginate_results
      @results = WillPaginate::Collection.create(self.page, per_page, self.result_count) do |pager|
        pager.replace @results
      end
    end

    # Parse important global attributes into instance variables
    def parse_attributes
      %w(num-results-requested result-count start).each do |node|
        if child = doc.root.xpath(node).first
          name = child.name.downcase.underscore
          value = child['type'] == 'integer' ? child.text.to_i : child.text
          instance_variable_set('@%s' % name, value)
        end
      end
    end

    # Parse the results into an array of DNZ::Result
    def parse_results
      @results = []
      doc.xpath('//results/result').each do |result_xml|
        @results << DNZ::Result.new(result_xml)
      end
    end

    # Parse the facets into an array of DNZ::FacetArray
    def parse_facets      
      @facets = FacetArray.new

      doc.xpath('//facets/facet').each do |facet_xml|
        @facets << DNZ::Facet.new(@client, @search, facet_xml)
      end
    end
  end
end