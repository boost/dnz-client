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
  # This class represents a digitalnz search API call. It should not be created directly. Instead
  # use the <tt>Client.search</tt> method.
  #
  # === Example
  #   search = client.search('text')
  #   puts "%d results found on %d pages" % [search.result_count, search.pages]
  class Search
    # The total number of results returned by the search
    attr_reader :result_count

    extend DNZ::Memoizable

    # Constructor for Search class. Do not call this directly, instead use the <tt>Client.search</tt> method.
    def initialize(client, search_options)
      @client = client
      @search_options = search_options

      execute
    end

    # The text used for searching
    def text
      @search_options[:search_text]
    end

    # The search options passed to the digitalnz API
    def options
      @search_options
    end

    # An array of results. If the mislav-will_paginate gem is installed this will return a paginated array.
    def results
      @results
    end

    # An array of facets.
    #
    # === Example
    #   search = client.search('text', :facets => 'category')
    #   categories = search.facets['category']
    #   categories.each do |category|
    #     puts '%d results in category %s' % [category.count, category.name]
    #   end
    def facets
      @facets
    end

    # The current page of results, based on the number of requested results and the start value
    # (see <tt>Client.search</tt>).
    def page
      (((@start || 0) / num_results_requested) + 1) rescue 1
    end

    # Set the page. This will update the search :start option and call the API again. The results array
    # will be replaced with the new page of results.
    def page=(new_page)
      @search_options['start'] = (new_page-1) * num_results_requested
      execute
    end

    # The number of pages available for the current search.
    def pages
      num_results_requested < result_count ? (result_count.to_f / num_results_requested).ceil : 0
    end

    # The number of results requested via the :num_results option (see <tt>Client.search</tt>).
    def num_results_requested
      @num_results_requested || 20
    end

    def inspect
      self.to_s
    end

    def to_s
      {
              :total_results => self.result_count,
              :results => self.results.length,
              :facets => self.facets.length,
              :page => self.page,
              :pages => self.pages
      }.inspect
    end

    # Return true if this search is using a custom search engine
    def custom_search?
      !@search_options.has_key?(:custom_search)
    end

    private

    # Turn the filter hash into an array of strings
    # in the format key:"value"
    def parsed_search_filter
      filter = @search_options[:filter]
      filter = {} unless filter.is_a?(Hash)
      filter.symbolize_keys!
      filter.map{|k, v| '%s:"%s"' % [k, v]}
    end

    memoize :parsed_search_filter

    # Join the search text with any filters with " AND "
    def parsed_search_text
      if parsed_search_filter.any?
        ([text] + parsed_search_filter).join(' AND ')
      else
        text
      end
    end

    # The facets option gets turned into a comma separated string
    def parsed_search_facets
      search_facets = @search_options[:facets] || []
      search_facets = search_facets.join(',') if search_facets.is_a?(Array)
      search_facets
    end

    # Turn the options into options acceptable for an API call.
    # Removes the filter option and parses the other options.
    def parsed_search_options
      parsed_options = @search_options.dup
      parsed_options.delete(:filter)

      parsed_options[:search_text] = parsed_search_text
      parsed_options[:facets] = parsed_search_facets

      parsed_options
    end

    memoize :parsed_search_options

    # Return a Nokogiri document for the XML
    def doc
      @doc ||= Nokogiri::XML(@xml)
    end

    # Choose which API call to make, either search or
    # custom_search if a custom search engine is specified.
    def execute_action
      if custom_search?
        :search
      else
        :custom_search
      end
    end

    # Execute the search by making the API call
    def execute
      reset

      @xml = @client.send(:fetch, execute_action, parsed_search_options)

      # Parse the results
      parse_attributes
      parse_facets
      parse_results
      paginate_results if defined? WillPaginate::Collection

      self
    end

    # Reset important instance variables
    def reset
      @doc = nil
      @results = nil
      @facets = nil
    end

    # Replace the results array with a paginated array
    def paginate_results
      @results = WillPaginate::Collection.create(self.page, num_results_requested, self.result_count) do |pager|
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
        @facets << DNZ::Facet.new(@client, self, facet_xml)
      end
    end
  end
end