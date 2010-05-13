require File.dirname(__FILE__) + '/../spec_helper'
require 'dnz/facet'

include DNZ

describe Facet do
  describe '::find' do
    before do
      @mock_facet = mock(:facet)
      @mock_facets = {'facet' => @mock_facet}
      @mock_search = mock(:search, :facets => @mock_facets)
      
      Client.stub!(:search).and_return(@mock_search)
    end
      
    context 'no search text' do
      it 'should search for *:*' do
        Client.should_receive(:search).with('*:*', anything).and_return(@mock_search)
        Facet.find('facet')
      end
    end
    
    context 'search text' do
      it 'should search for the search text' do
        Client.should_receive(:search).with('search text', anything).and_return(@mock_search)
        Facet.find('facet', 'search text')
      end
    end
    
    it 'should pass the facet to the facets option' do
      Client.should_receive(:search).with(anything, hash_including(:facets => 'facet'))
      Facet.find('facet')
    end
    
    it 'should set num_results to 0' do
      Client.should_receive(:search).with(anything, hash_including(:num_results => 0))
      Facet.find('facet')
    end
    
    context 'num_results not specified' do
      it 'should set facet_num_results to -1' do
        Client.should_receive(:search).with(anything, hash_including(:facet_num_results => -1))
        Facet.find('facet')
      end
    end
    
    context 'num_results specified' do
      it 'should set facet_num_results to the specified number' do
        Client.should_receive(:search).with(anything, hash_including(:facet_num_results => 13))
        Facet.find('facet', nil, 13)
      end
    end
  end
  
  describe '::find_related' do
    before do
      @mock_facet = mock(:facet)
      @mock_facets = {'facet' => @mock_facet}
      @mock_search = mock(:search, :facets => @mock_facets)
      
      Client.stub!(:search).and_return(@mock_search)
    end
      
    context 'no search text' do
      it 'should search for *:* AND parent_facet:"value"' do
        Client.should_receive(:search).with('*:* AND parent_facet:"value"', anything).and_return(@mock_search)
        Facet.find_related('facet', 'parent_facet', 'value')
      end
    end
    
    context 'search text' do
      it 'should search for the search text' do
        Client.should_receive(:search).with('search text AND parent_facet:"value"', anything).and_return(@mock_search)
        Facet.find_related('facet', 'parent_facet', 'value', 'search text')
      end
    end
    
    it 'should pass the facet to the facets option' do
      Client.should_receive(:search).with(anything, hash_including(:facets => 'facet'))
      Facet.find_related('facet', 'parent_facet', 'value')
    end
    
    it 'should set num_results to 0' do
      Client.should_receive(:search).with(anything, hash_including(:num_results => 0))
      Facet.find_related('facet', 'parent_facet', 'value')
    end
    
    context 'num_results not specified' do
      it 'should set facet_num_results to -1' do
        Client.should_receive(:search).with(anything, hash_including(:facet_num_results => -1))
        Facet.find_related('facet', 'parent_facet', 'value')
      end
    end
    
    context 'num_results specified' do
      it 'should set facet_num_results to the specified number' do
        Client.should_receive(:search).with(anything, hash_including(:facet_num_results => 13))
        Facet.find_related('facet', 'parent_facet', 'value', nil, 13)
      end
    end
  end
  
  describe 'instance' do
    before(:each) do
      @client = mock(:client)
      @search = mock(:search)
      @search.stub!(:text).and_return('test')
      @xml = %Q{<?xml version="1.0"?>
        <facet>
        <facet-field>My name</facet-field>
        <values>
        <value>
        <name>Value name</name>
        <num-results>23</num-results>
        </value>
        </values>
        </facet>
      }

      @doc = Nokogiri::XML(@xml).root
    end

    describe 'Facet.new' do
      before(:each) do
        @facet = Facet.new(@client, @search, @doc)
      end

      it 'should have the correct name' do
        @facet.name.should == 'My name'
      end

      describe '#values' do
        it 'should have an array of values' do
          @facet.values.should be_a(Array)
        end

        it 'should have one value' do
          @facet.values.size.should == 1
        end

        it 'should have a value with name Value name' do
          @facet.values.first.name.should == 'Value name'
        end

        it 'should have a value with 23 results' do
          @facet.values.first.count.should == 23
        end
      end

      describe '#[]' do
        it 'should return the facet by name index' do
          @facet['Value name'].name.should == 'Value name'
          @facet['Value name'].count.should == 23
        end
      end

      describe '#each' do
        it 'should loop over the values' do
          @facet.each do |value|
            value.name.should == 'Value name'
          end
        end
      end
    end
  end
end