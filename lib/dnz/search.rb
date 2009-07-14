require 'nokogiri'
require 'dnz/result'
require 'dnz/facet'

module DNZ
  class Search

    attr_reader :results
    attr_reader :facets

    def initialize(client, xml)
      @client = client
      @xml = xml
      @doc = Nokogiri::XML(@xml)

      parse_results
      parse_facets
    end

    private

    def parse_results
      @results = []

      @doc.xpath('//results/result').each do |result_xml|
        @results << DNZ::Result.new(result_xml)
      end
    end

    def parse_facets
      @facets = []

      @doc.xpath('//facets/facet').each do |facet_xml|
        @facets << DNZ::Facet.new(@client, facet_xml)
      end
    end
  end
end