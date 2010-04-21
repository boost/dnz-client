require File.dirname(__FILE__) + '/../spec_helper'
require 'dnz/search'

include DNZ

describe Results do
  before(:each) do
    @xml = %Q{<?xml version="1.0"?>
<response>
  <result-count type="integer">1</result-count>
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
    @result = mock(:result)
    @facet = mock(:facet)

    Result.stub!(:new).and_return(@result)
    Facet.stub!(:new).and_return(@facet)
    
    @instance = Results.new(@xml)
  end
  
  describe '#result_count' do
    subject { @instance.result_count }
    it { should == 1 }
  end
  
  describe '#facets' do
    subject { @instance.facets }
    it { should == [@facet] }
  end
  
  describe '#results' do
    subject { @instance.results }
    it { should == [@result] }
  end
  
  describe '#page' do
    subject { @instance.page }
    it { should == 1 }
  end
  
  describe '#pages' do
    subject { @instance.pages }
    it { should == 1 }
  end
  
  describe '#num_results_requested' do
    subject { @instance.num_results_requested }
    it { should == 20 }
  end
end
