require File.dirname(__FILE__) + '/../spec_helper'
require 'dnz/facet'

include DNZ

describe Facet do
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