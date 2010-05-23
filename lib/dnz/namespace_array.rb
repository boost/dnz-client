# This class takes an array of Nokogiri::XML::Element objects and
# makes them accessible by namespace and node name.
#
# Example:
#
# <dc:title>Test</dc:title>
# <dnz:tag>ok</dnz:tag>
# <dnz:content_partner>National Library</dnz:content_partner>
#
# @array.dc.size => 1
# @array.dnz.size => 2
# @array.dc.title.text => Test
# @array.dnz.tag.text => ok
#
# Namespace is optional:
# @array.title.text => Test
#
# Return value is another NamespaceArray:
# @array.dnz.class => NamespaceArray
#
module DNZ
  class NamespaceArray < Array
    def [](index)
      if index.is_a?(String)
        if (nodes = self.select{|node| node.namespace.prefix.downcase.to_s == index }).any?
          return NamespaceArray.new(nodes)
        end

        if (nodes = self.select{|node| node.name == index }).any?
          return NamespaceArray.new(nodes)
        end

        NamespaceArray.new
      else
        super
      end
    end

    def type
      self['type']
    end

    # An array of all unique node names in this array.
    def names
      map(&:name).map(&:downcase).uniq
    end

    # An array of all unique namespaces in this array.
    def namespaces
      map(&:namespace).map(&:prefix).map(&:to_s).map(&:downcase).uniq
    end

    # The combined text of all nodes in this array.
    def text
      map(&:text).join
    end

    def inspect
      namespaces.collect {|namespace| '%s => [ %s ]' % [namespace, self[namespace].names.join(', ')] }.join(', ')
    end

    def method_missing(symbol, *args, &block)
      method = symbol.to_s

      if method =~ /(.*)\?$/
        self[$1].any?
      elsif self.length == 1 && self.first.respond_to?(symbol)
        self.first.send(symbol, *args, &block)
      elsif args.empty?
        self[method]
      end
    end
  end
end