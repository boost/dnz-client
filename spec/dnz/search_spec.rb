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
  end

  describe 'Search.new' do
    it 'should create one result' do
      Result.should_receive(:new).and_return(@result)
      Search.new(@client, @options, @xml).results.should == [@result]
    end

    it 'should create one facet' do
      Facet.should_receive(:new).and_return(@facet)
      Search.new(@client, @options, @xml).facets.should == [@facet]
    end
  end
end