require 'nokogiri'
require 'dnz/results'
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

    # Set the page. This will update the search :start option and call the API again. The results array
    # will be replaced with the new page of results.
    def page=(new_page)
      @search_options['start'] = (new_page-1) * num_results_requested
      execute
    end

    def inspect
      self.to_s
    end

    def to_s
      {
              :results => self.result_count,
              :facets => self.facets.length,
              :page => self.page,
              :pages => self.pages,
              :per_page => self.num_results_requested
      }.inspect
    end

    # Return true if this search is using a custom search engine
    def custom_search?
      !@search_options.has_key?(:custom_search)
    end

    def method_missing(method, * args, & block)
      if @results
        @results.send(method, * args, & block)
      else
        super
      end
    end

    private

    # Combine an array of search terms into a term separated by AND
    #
    # If the last argument is true then the search terms will be wrapped
    # in brackes. For example,
    #
    #   combine_search_terms('term 1', 'term 2', true) => '(term 1) AND (term 2)'.
    #
    # This is useful for wrapping pre-combined terms:
    #
    #   combine_search_terms('id:123 OR id:321', 'content_partner:"penfold"') => '(id:123 OR id:321) AND (content_partner:"penfold")'
    #
    def combine_search_terms(* args)
      args.flatten!
      separate = args.last == true || args.last == false ? args.pop : false
      args = args.map { |term| term.to_s.strip }.reject(& :blank?).compact
      args.map! { |term| '(%s)' % term } if separate
      args.join(' AND ')
    end

    # Turn the filter hash into an array of strings
    # in the format key:"value"
    def parsed_search_filter
      filter = @search_options[:filter]
      filter = {} unless filter.is_a?(Hash)
      filter.symbolize_keys!
      filter.map do |k, v|
        if v.is_a?(Array)
          # OR together multiple values for the same filter
          '(' + v.map { |i| '%s:"%s"' % [k, i] }.join(' OR ') + ')'
        else
          '%s:"%s"' % [k, v]
        end
      end
    end

    memoize :parsed_search_filter

    # Join the search text with any filters with " AND "
    def parsed_search_text
      if parsed_search_filter.any?
        combine_search_terms(text, parsed_search_filter, true)
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
      @xml = @client.send(:fetch, execute_action, parsed_search_options)
      @results = DNZ::Results.new(@xml, self)

      self
    end
  end
end
