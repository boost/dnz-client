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
      options[:search_text] = text
      @xml = fetch(:search, options)
      DNZ::Search.new(self, @xml)
    end

    private

    def fetch(path, options = {})
      validate_options(path, options)

      options = options.reverse_merge(:api_key => self.api_key)
      qs = options.map{|k,v| '%s=%s' % [k,v] }.join('&')
      url = self.base_url + '/' + PATHS[path].gsub('${version}', self.version) + '?' + qs
      open(url)
    end

    def validate_options(path, options = {})
      if ARGS.has_key?(path) && !Set.new(options.keys).subset?(ARGS[path])
        raise ArgumentError.new("Valid options for #{path} are: #{ARGS[path].join(', ')}")
      end
    end
  end
end