require File.dirname(__FILE__) + '/../spec_helper'
require 'dnz/facet_array'

include DNZ

describe FacetArray do
  before do
    @facet_1 = mock(:facet_1, :name => 'facet 1')
    @facet_2 = mock(:facet_2, :name => 'facet 2')
    @facet_3 = mock(:facet_3, :name => 'facet 3')
    @facet_4 = mock(:facet_4, :name => 'facet 3')

    @array = FacetArray.new
    @array << @facet_1
    @array << @facet_2
    @array << @facet_3
  end
  
  describe '#[]' do
    it 'should return items by name' do
      @array[0].should == @facet_1
      @array['facet 1'].should == @facet_1
      @array[1].should == @facet_2
      @array['facet 2'].should == @facet_2
      @array[2].should == @facet_3
      @array['facet 3'].should == @facet_3
    end
  end
  
  describe '#names' do
    it 'should return an array of facet names' do
      @array.names.should == ['facet 1', 'facet 2', 'facet 3']
    end
  end 
end