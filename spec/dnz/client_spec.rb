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
      @client.should_receive(:open).with('http://api.digitalnz.org/records/v1.xml/?api_key=abc&search_text=*:*')
      @client.fetch(:search, :search_text => '*:*')
    end
  end
end