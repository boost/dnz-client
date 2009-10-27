require 'dnz/record/metadata'
require 'dnz/record/metadata_array'
require 'dnz/record/namespace_array'

module DNZ
  module Record
    class Base
      include DNZ::Record
      
      attr_reader :id, :document

      # Initialize a new record passing it the ID and the XML returned from the item service.
      #
      # id:: The id of the record
      # xml:: XML string that represents the record data
      def initialize(id, xml)
        @id = id
        @document = Nokogiri.XML(xml.to_s)
        @data = NamespaceArray.new
        @document.xpath('//xmlns:xmlData').each do |xdata|
          xdata.children.each do |child|
            if child.element?
              @data << child
            end
          end
        end
      end

      # Return a MetadataArray for this record.
      def metadata
        load_metadata unless @metadata
        @metadata
      end

      # Add additional user contributed metadata to this object. This function will call the
      # item service. The return value will be an HTTP status code, 201 for success.
      #
      # schema:: The schema of the contributed data. Example: dnz
      # key:: The key name of the contributed data. Example: tag
      # data:: The value to be stored
      # api_key:: An API key to be stored with the data
      # email_address:: An email address to tbe stored with the data
      #
      # The email address will be hashed using MD5.
      def add_ucm_data(schema, key, data, api_key, email_address)
        email_hash = Digest::MD5.hexdigest(email_address)
        self.class.remote_post_metadata(id, schema, key, data, api_key, email_hash)
      end

      # extract the access url from the metadata 
      def source_url
        landing_url = self.dnz.landing_url.first.text rescue nil
        collection = self.dnz.collection.first.text rescue nil

        if collection && collection =~ /Shared Research Repository/
          url = 'http://%s' % HOSTED_SEARCH_DOMAIN
          url << ':%d' % HOSTED_SEARCH_PORT unless HOSTED_SEARCH_PORT == 80
          url << '/records/%d.html' % id
          return url
        end

        unless landing_url.blank?
          url = landing_url

          #the service layer seems to double encode ampersands
          url.gsub!('&amp;amp;', '&')
          url.gsub!('&amp;', '&')
          return url
        end

        return nil
      end

      def inspect
        "Record{ %s }" % @data.inspect
      end

      def to_s
        @document.to_s
      end

      def type
        @data.type
      end

      def method_missing(method, *args, &block)
        if attribute = document.root.attributes[method.to_s.upcase]
          attribute.to_s
        else
          @data.send(method, *args, &block)
        end
      end

      private

      def load_metadata
        @metadata = MetadataArray.new(@data.collect do |node|
          user_contributed = node.attributes['type'].to_s == 'user'
          Metadata.new(self, node.namespace.prefix.to_s, node.name, node.text, user_contributed)
        end)
      end
    end
  end
end
