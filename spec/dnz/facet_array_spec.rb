require File.dirname(__FILE__) + '/../spec_helper'
require 'dnz/facet_array'

include DNZ

describe FacetArray do
  describe '#[]' do
    it 'should return items by name' do
      facet_1 = mock(:facet_1, :name => 'facet 1')
      facet_2 = mock(:facet_2, :name => 'facet 2')
      facet_3 = mock(:facet_3, :name => 'facet 3')

      array = FacetArray.new
      array << facet_1
      array << facet_2
      array << facet_3

      array[0].should == facet_1
      array['facet 1'].should == facet_1
      array[1].should == facet_2
      array['facet 2'].should == facet_2
      array[2].should == facet_3
      array['facet 3'].should == facet_3
    end
  end
end