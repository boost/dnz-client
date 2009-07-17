require 'nokogiri'
require 'dnz/result'
require 'dnz/facet'

begin
  gem 'mislav-will_paginate' rescue nil
  require 'will_paginate/collection' rescue nil
rescue LoadError => e
end

module DNZ
  class Search
    attr_reader :result_count

    def initialize(client, search_options)
      @client = client
      @search_options = search_options

      execute
    end

    def text
      @search_options[:search_text]
    end

    def options
      @search_options
    end

    def results
      if @results.nil?
        parse_results
        paginate_results if defined? WillPaginate::Collection
      end

      @results
    end

    def facets
      parse_facets if @facets.nil?
      @facets
    end

    def page
      (((@start || 0) / num_results_requested) + 1) rescue 1
    end

    def page=(new_page)
      @search_options['start'] = (new_page-1) * num_results_requested
      execute
    end

    def pages
      num_results_requested < result_count ? (result_count.to_f / num_results_requested).ceil : 0
    end

    def num_results_requested
      @num_results_requested || 20
    end

    def to_s
      {
        :results => self.results.length,
        :facets => self.facets.length,
        :page => self.page,
        :pages => self.pages
      }.inspect
    end

    private

    def doc
      @doc ||= Nokogiri::XML(@xml)
    end

    def execute
      @doc = nil
      @results = nil
      @facets = nil
      @xml = @client.send(:fetch, :search, @search_options)

      parse_attributes

      self
    end

    def paginate_results
      @results = WillPaginate::Collection.create(self.page, num_results_requested, self.result_count) do |pager|
        pager.replace @results
      end
    end

    def parse_attributes
      %w(num-results-requested result-count start).each do |node|
        if child = doc.root.xpath(node).first
          name = child.name.downcase.underscore
          value = child['type'] == 'integer' ? child.text.to_i : child.text
          instance_variable_set('@%s' % name, value)
        end
      end
    end

    def parse_results
      @results = []
      doc.xpath('//results/result').each do |result_xml|
        @results << DNZ::Result.new(result_xml)
      end
    end

    def parse_facets
      @facets = []

      doc.xpath('//facets/facet').each do |facet_xml|
        @facets << DNZ::Facet.new(@client, facet_xml)
      end
    end
  end
end