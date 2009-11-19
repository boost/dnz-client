require File.dirname(__FILE__) + '/../spec_helper'
require 'dnz/client'

include DNZ

describe Client do
  before(:each) do
    @client = Client.new('abc')
    @client.stub!(:open) # make sure open is never called
    @search = mock(:search)
    DNZ::Search.stub!(:new).and_return(@search)
  end
  
  describe 'APIs' do
    describe 'v1' do
      before do
        @version = 'v1'
        @client = Client.new('abc', @version)
        @client.stub!(:open) # make sure open is never called
      end
      
      describe 'search' do        
        [:search_text,:api_key,:num_results,:start,:sort,:direction,:facets,:facet_num_results,:facet_start].each do |option|
          it "should allow #{option}" do
            lambda do
              @client.send(:fetch, :search, {option => "test"})
            end.should_not raise_error(ArgumentError)
          end
        end 
      end
      
      describe 'custom_search' do
        it 'should require custom_search' do
          lambda do
            @client.send(:fetch, :custom_search, {}) 
          end.should raise_error(ArgumentError, "Required argument missing: custom_search")
        end
        
        [:search_text,:api_key,:num_results,:start,:sort,:direction].each do |option|
          it "should allow #{option}" do
            lambda do
              @client.send(:fetch, :custom_search, {:custom_search => "test", option => "test"})
            end.should_not raise_error(ArgumentError)
          end
        end
        [:facets,:facet_num_results,:facet_start].each do |option|
          it "should not allow #{option}" do
            lambda do
              @client.send(:fetch, :custom_search, {:custom_search => "test", option => "test"})
            end.should raise_error(ArgumentError)
          end
        end
      end
    end
    
    describe 'v2' do
      before do
        @version = 'v2'
        @client = Client.new('abc', @version)
        @client.stub!(:open) # make sure open is never called
      end
      
      describe 'search' do
        [:search_text,:api_key,:num_results,:start,:sort,:direction,:facets,:facet_num_results,:facet_start].each do |option|
          it "should allow #{option}" do
            lambda do
              @client.send(:fetch, :search, {})
            end.should_not raise_error(ArgumentError)
          end
        end 
      end
      
      describe 'custom_search' do
        it 'should require custom_search' do
          lambda do
            @client.send(:fetch, :custom_search, {}) 
          end.should raise_error(ArgumentError, "Required argument missing: custom_search")
        end
        
        [:search_text,:api_key,:num_results,:start,:sort,:direction].each do |option|
          it "should allow #{option}" do
            lambda do
              @client.send(:fetch, :custom_search, {:custom_search => "test", option => "test"})
            end.should_not raise_error(ArgumentError)
          end
        end
        [:facets,:facet_num_results,:facet_start].each do |option|
          it "should allow #{option}" do
            lambda do
              @client.send(:fetch, :custom_search, {:custom_search => "test", option => "test"})
            end.should_not raise_error(ArgumentError)
          end
        end
      end
    end
  end
  

  describe '#search' do
    it 'should create a new search object and return it' do
      @client.search('*:*').should be(@search)
    end
  end

  describe '#fetch' do
    it 'should raise an error an invalid option is set' do
      lambda do
        @client.fetch(:search, :blahblah => 'dlfkgj')
      end.should raise_error(ArgumentError)
    end

    it 'should call open with query string arguments' do
      @client.should_receive(:open).with do |url|
        url.should include('http://api.digitalnz.org/records/v1.xml/?')
        url.should include('api_key=abc')
        url.should include('search_text=%2A%3A%2A')
      end
      @client.fetch(:search, :search_text => '*:*')
    end
    
    it 'should raise an InvalidApiKey error if the status is 401' do
      @client.should_receive(:open).and_raise(OpenURI::HTTPError.new('401 Unauthorized', nil))
      lambda do
        @client.fetch(:search, :search_text => '*:*')
      end.should raise_error(InvalidApiKeyError)
    end
  end
  
  describe '#categories' do
    before do
      @categories = mock(:categories)
      @category = mock(:facet)
      @category.stub!(:values).and_return(@categories)
      @facets = mock(:facets)
      @facets.stub!(:[]).with('category').and_return(@category)
      @search.stub!(:facets).and_return(@facets)
      @client.stub!(:search).and_return(@search)
    end
    
    it 'should run a search for categories facet' do
      @client.should_receive(:search).with('*:*', :facets => 'category', :facet_num_results => 100).and_return(@search)
      @client.categories
    end

    it 'should run a search with custom_search' do
      @client.should_receive(:search).with('*:*', :facets => 'category', :facet_num_results => 100, :custom_search => 'test').and_return(@search)
      @client.categories(:custom_search => 'test')
    end
    
    it 'should return the categories facet' do
      @client.categories.should == @categories
    end
  end
end