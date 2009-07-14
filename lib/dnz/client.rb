require 'rubygems'
require 'open-uri'
require 'set'
require 'active_support'
require 'dnz/search'

module DNZ
  class Client
    attr_reader :api_key
    attr_reader :base_url
    attr_reader :version

    PATHS = {
      :search => 'records/${version}.xml/'
    }

    ARGS = {
      :search => Set.new([
        :search_text,
        :api_key,
        :num_results,
        :start,
        :sort,
        :direction,
        :facets,
        :facet_num_results,
        :facet_start
      ])
    }

    def initialize(api_key, base_url = 'http://api.digitalnz.org', version = 'v1')
      @api_key = api_key
      @base_url = base_url
      @version = version
    end

    def categories
      search('*:*', :facets => 'category', :facet_num_results => 100).facets.detect{|f| f.name == 'category'}.values
    end

    def search(text, options = {})
      options.reverse_merge!(
        :search_text => text,
        :num_results => 20,
        :start => 0
      )

      # Select the correct page
      page = options.delete(:page)
      options[:start] = (page-1) * options[:num_results] if page

      DNZ::Search.new(self, options)
    end  

    def fetch(path, options = {})
      validate_options(path, options)

      options = options.reverse_merge(:api_key => self.api_key)
      qs = options.map{|k,v| '%s=%s' % [k,v] }.join('&')
      url = self.base_url + '/' + PATHS[path].gsub('${version}', self.version) + '?' + qs
      open(url)
    end

    private

    def validate_options(path, options = {})
      options.symbolize_keys!

      if ARGS.has_key?(path) && !Set.new(options.keys).subset?(ARGS[path])
        raise ArgumentError.new("Valid options for #{path} are: #{ARGS[path].to_a.join(', ')}, provided: #{options.keys.join(', ')}")
      end
    end
  end
end