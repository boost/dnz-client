require 'dnz/attributes'

module DNZ
  class Facet
    attr_reader :name
    attr_reader :values

    def initialize(client, doc)
      @name = doc.xpath('facet-field').text
      @values = []

      doc.xpath('values').first.children.each do |value_doc|
        value = DNZ::FacetValue.new(client, self, value_doc)
        @values << value if value.valid?
      end
    end
  end

  class FacetValue
    attr_reader :name, :count

    def initialize(client, facet, doc)
      @client = client
      @facet = facet
      @name = doc.xpath('name').text
      @count = doc.xpath('num-results').text.to_i
    end

    def valid?
      !self.name.blank?
    end

    def search(text, options = {})
      @client.search('%s:%s %s' % [@facet.name, self.name, text], options)
    end

    def inspect
      {:name => self.name, :count => self.count}.inspect
    end

    def to_s
      self.name
    end
  end
end