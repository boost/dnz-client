require File.dirname(__FILE__) + '/../spec_helper'
require 'dnz/search'

include DNZ

describe Search do
  before(:each) do
    @xml = %Q{<?xml version="1.0"?>
<response>
  <results>
    <result>
      <attribute>test</attribute>
    </result>
  </results>
  <facets>
    <facet>
      <value>test</value>
    </facet>
  </facets>
</response>
    }

    @doc = Nokogiri::XML(@xml)
    @client = mock(:client)
    @result = mock(:result)
    @facet = mock(:facet)
    @options = {:search_text => 'test'}

    Result.stub!(:new).and_return(@result)
    Facet.stub!(:new).and_return(@facet)
    
    @client.stub!(:fetch).and_return(@xml)
  end

  describe 'Search.new' do
    it 'should call @client.fetch' do
      @client.should_receive(:fetch).with(:search, :search_text => 'test', :facets => "").and_return(@xml)
      Search.new(@client, @options)
    end

    it 'should create one result' do
      Result.should_receive(:new).and_return(@result)
      Search.new(@client, @options).results.should == [@result]
    end

    it 'should create one facet' do
      Facet.should_receive(:new).and_return(@facet)
      Search.new(@client, @options).facets.should == [@facet]
    end

    it 'should return facets as a FacetArray' do
      Search.new(@client, @options).facets.should be_a(FacetArray)
    end
  end
  
  describe 'filtering' do
    before do
      @options = {:search_text => 'test', :filter => {:category => 'Images'}}
    end
    
    it 'should call @client.fetch with the search text set to \'test AND category:"Images"\'' do
      @client.should_receive(:fetch).with(
        :search,
        :search_text => 'test AND category:"Images"',
        :facets => ""
      ).and_return(@xml)
      Search.new(@client, @options)
    end
  end
end