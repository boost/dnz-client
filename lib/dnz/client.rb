require 'rubygems'
require 'open-uri'
require 'set'
require 'active_support'
require 'dnz/search'
require 'dnz/error/invalid_api_key'

module DNZ
  # This is a simple client for accessing the digitalnz.org API
  # for searching New Zealand's digital content. It provides
  # access to search results and facet information.
  #
  # Author:: Jeremy Wells, Boost New Media (http://www.boost.co.nz)
  # Copyright:: Copyright (c) 2009 Boost New Media
  # License:: MIT
  class Client
    # The dnz API key
    attr_reader :api_key
    # The base URL (defaults to http://api.digitalnz.org)
    attr_reader :base_url
    # The version of the API to use (defaults to v1)
    attr_reader :version

    APIS = {
      :search => 'records/${version}.xml/',
      :custom_search => 'custom_searches/${version}/${title}.xml'
    }

    ARGS = {
      :v1 => {
        :search => Set.new([
          :search_text,
          :api_key,
          :num_results,
          :start,
          :sort,
          :direction,
          :facets,
          :facet_num_results,
          :facet_start,
        ])
      }
    }

    # List of available facets that can be passed to search
    FACETS = [
      :category, :content_partner, :creator, :language, :rights, :century, :decade, :year
    ]

    # Constructor method for the Client class. An API key must be provided.
    # The base url and version default to "http://api.digitalnz.org" and "v1".
    #
    # ==== Example
    #   client = DNZ::Client.new('abcdefghijklmnoq')
    #   search = client.search('some text')
    #   search.results.each do |result|
    #     puts result.title
    #   end
    def initialize(api_key, base_url = 'http://api.digitalnz.org', version = 'v1')
      @api_key = api_key
      @base_url = base_url
      @version = version
    end

    # Get a list of all categories using the 'category' facet.
    #
    # ==== Example
    #   categories = client.categories
    #   categories.each do |category|
    #     puts category.name
    #   end
    def categories
      search('*:*', :facets => 'category', :facet_num_results => 100).facets['category'].values
    end

    # Run a search using the digitalnz.org API.
    #
    # ==== Options
    #
    # * <tt>:num_results</tt> - The number of results to return in this call. Defaults to 20.
    # * <tt>:start</tt> - The starting offset of the results.
    # * <tt>:facets</tt> - The facets to return for this search.
    # * <tt>:filter</tt> - A hash of filters to apply to the results
    #
    # ==== Example
    #   search = client.search('rubgy', :num_results => 50)
    #   search.results.each_with_index do |result, index|
    #     puts "#{index+1}: #{result.title}"
    #   end
    def search(text, options = {})
      options.reverse_merge!(
        :search_text => text,
        :num_results => 20,
        :start => 0,
        :filter => {}
      )

      # Select the correct page
      page = options.delete(:page)
      options[:start] = (page-1) * options[:num_results] if page

      DNZ::Search.new(self, options)
    end  

    # Make a direct call to the digitalnz.org API.
    #
    # * <tt>api</tt> - The api call to make. This must be listed in the APIS constant.
    # * <tt>options</tt> - A hash of options to pass to the API call. These options must be defined in the ARGS constant.
    def fetch(api, options = {})
      validate_options(api, options)

      options = options.reverse_merge(:api_key => self.api_key)

      #api_url = APIS[url]
      #matches = (/\$\{(.*?)\}/)
      #
      #
      #

      # qs = options.map{|k,v| '%s=%s' % [k,v] }.join('&')
      qs = options.to_query
      url = self.base_url + '/' + APIS[api].gsub('${version}', self.version) + '?' + qs
      
      begin
        open(url)
      rescue OpenURI::HTTPError => e
        if e.to_s =~ /^401/
          raise InvalidApiKeyError.new(self.api_key)
        else
          raise
        end
      end
    end

    private

    def validate_options(path, options = {})
      options = options.symbolize_keys
      
      version_args = ARGS[@version.to_sym]

      if version_args.has_key?(path) && !Set.new(options.keys).subset?(version_args[path])
        raise ArgumentError.new("Valid options for #{path} are: #{version_args[path].to_a.join(', ')}, provided: #{options.keys.join(', ')}")
      end
    end
  end
end