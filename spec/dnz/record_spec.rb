require File.dirname(__FILE__) + '/../spec_helper'
require 'nokogiri'

include DNZ

describe Record do
  before(:each) do
    @xml = %Q{<?xml version="1.0" encoding="UTF-8" standalone="no"?>
                <mets OBJID="oai:horowhenua.kete.net.nz:site:StillImage:12647" PROFILE="GDL-NLNZ" xmlns="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd">
                 <dmdSec ID="dc">
                  <mdWrap MIMETYPE="text/xml" MDTYPE="DC">
                   <xmlData xmlns:dc="http://www.example.com/example">
                    <dc:creator>Pippa</dc:creator>
                    <dc:creator>pmc1</dc:creator>
                    <dc:date>2008-03-06T00:00:00.000Z</dc:date>
                    <dc:description>Pippa&amp;amp;#39;s test&amp;amp;nbsp;</dc:description>
                    <dc:format>image/gif</dc:format>
                    <dc:identifier>GIF-109</dc:identifier>
                    <dc:publisher>horowhenua.kete.net.nz</dc:publisher>
                    <dc:published>horowhenua.kete.net.nz</dc:published>
                    <dc:relation>http://horowhenua.kete.net.nz/site/topics/show/1816</dc:relation>
                    <dc:rights>http://creativecommons.org/licenses/by-nc-sa/3.0/nz/</dc:rights>
                    <dc:subject>Test layout 1</dc:subject>
                    <dc:subject>Test layout 2</dc:subject>
                    <dc:title>test angel</dc:title>
                    <dc:type>InteractiveResource</7dc:type>
                    <dc:type>AnotherType</dc:type>
                    <dc:source>Example source</dc:source>
                   </xmlData>
                  </mdWrap>
                 </dmdSec>
                 <dmdSec ID="dnz">
                  <mdWrap MIMETYPE="text/xml" MDTYPE="OTHER">
                   <xmlData xmlns:dnz="http://www.example.com/example">
                    <dnz:category>Images</dnz:category>
                    <dnz:collection>Kete Horowhenua</dnz:collection>
                    <dnz:content_partner>Kete Horowhenua Partner</dnz:content_partner>
                    <dnz:landing_url>http://horowhenua.kete.net.nz/site/images/show/12647-test-angel</dnz:landing_url>
                    <dnz:object_url>http://horowhenua.kete.net.nz/image_files/0000/0006/6611/bleangel.gif</dnz:object_url>
                    <dnz:thumbnail_url>http://horowhenua.kete.net.nz/image_files/0000/0006/6611/bleangel_medium.gif</dnz:thumbnail_url>
                    <dnz:tag type="user" namespace="moe::status::">restricted</dnz:tag>
                   </xmlData>
                  </mdWrap>
                 </dmdSec>}

    @client = mock(:client)
    @record = mock(:record)

    Record.stub!(:find).and_return(@record)
    @client.stub!(:fetch).and_return(@xml)
  end

  describe 'Record.new' do
    it 'should call @client.fetch' do
      @client.should_receive(:fetch).with(:record, :id => 123)
      Record.new(@client, 123)
    end
    
    it 'should call @client.fetch' do
      @client.should_receive(:fetch).with(:record,  :id => 123).and_return(@xml)
      Record.new(@client, 123)
    end

    it 'should create one result' do
      Record.should_receive(:new).and_return(@record)
      Record.new(@client, @options).should == @record
    end
  end

  
  describe 'Record.find' do 
    it 'should create one result' do
      Record.should_receive(:find).and_return(@doc)
      Record.find(123).should == @doc
    end
  end
end



