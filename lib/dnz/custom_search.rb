require 'nokogiri'
require 'dnz/result'
require 'dnz/facet_array'
require 'dnz/facet'
require 'dnz/memoizable'

# Load will_paginate if it's available
# to provide pagination
begin
  gem 'mislav-will_paginate' rescue nil
  require 'will_paginate/collection' rescue nil
rescue LoadError => e
end

module DNZ
  class CustomSearch
    attr_reader :attributes
    
    def initialize(client, attributes = {})
      @client = client
      @attributes = attributes
    end
    
    def [](key)
      @attributes[key]
    end
    
    def []=(key, value)
      @attributes[key] = value
    end
    
    def method_missing(method, *args, &block)
      if @attributes.has_key?(method.to_sym)
        @attributes[method.to_sym]
      else
        super
      end
    end
    
    def preview
      options = {:validate => false, :search_text => '*:*'}
      attributes.each do |key, value|
        options['custom_search[%s]' % key] = value
      end
      
      xml = @client.fetch(:custom_search_preview, options)
      DNZ::Results.new(xml, self)
    end
    
    def text
      attributes[:search_term] || ''
    end
  end
end
    