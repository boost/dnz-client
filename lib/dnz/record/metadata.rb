module DNZ
  module Record
    # This class represents a metadata item returned as part of a Record from the item service. Metadata
    # items hold a schema, a name and a value. The schema is determined by the XML namespace prefix
    # returned by the item service.
    #
    # The value of each metadata item can be namespaced using double colons (::). For example,
    # the value moe::status::restricted would be considered to be in the moe namespace, status namespace
    # with the value restricted. The value method honors namespaces.
    class Metadata
      attr_reader :record, :schema, :name

      # Metadata items are usually created by a Record object.
      #
      # record:: The record object this metadata belongs to.
      # schema:: The schema of the item. This is the XML namespace prefix of the tag returned by the items service.
      # name:: The name of the item.
      # value:: The value of the item.
      # user_contributed:: Boolean value specifying if this item was contributed by a user.
      def initialize(record, schema, name, value, user_contributed = false)
        @record = record
        @schema = schema
        @name = name
        @value = value
        @user_contributed = user_contributed
      end

      # Was this item contributed by a user?
      def user_contributed?
        !!@user_contributed
      end

      # The value of the item. This value has the namespace removed. For example, if the item service
      # returns the value "test" then the value will be "test". If the item service returns
      # the value "moe::test" then this value is considered to be in the moe namespace. In this instance
      # value will return "test".
      def value
        @stored_value ||= @value.split(/::/).last
      end

      # Return the full value including the namespace.
      def full_value
        @value
      end

      # The namespace of the metadata represented as an array. For example, if an item had a value
      # of moe::status::restricted then this function would return ['moe', 'status']
      def namespace
        @namespace ||= @value.split(/::/)[0..-2]
      end

      # Is this metadata in the specified namespace?
      #
      # Example: moe::status::restricted
      #   in_namespace?('moe') => true
      #   in_namespace?('moe::status') => true
      #   in_namespace?('moe::status::restricted') => true
      #   in_namespace?('moe::other') => false
      #
      # Namespaced metadata is not considered to be in the root namespace.
      # Only non-namespaced metadata is in the root namespace:
      #
      # Example: moe::status::restricted
      #   in_namespace?('') => false
      #
      # Example: tag
      #   in_namespace('') => true
      #
      def in_namespace?(namespace)
        return false if namespace.blank? && !self.namespace.empty?
        return false if !namespace.blank? && self.namespace.empty?
        return true if namespace.blank? && self.namespace.empty?

        namespace = namespace.split(/::/)
        namespace_with_value[0, namespace.length] == namespace
      end

      def to_s
        full_value
      end

      def inspect
        '%s:%s %s' % [schema, name, full_value]
      end

      def to_json
        {
                :schema => schema,
                :name => name,
                :value => value,
                :namespace => namespace.join('::')
        }.to_json
      end

      def to_tag
        tag = '<'
        tag << schema
        tag << ':'
        tag << name

        if user_contributed?
          tag << ' type="user"'
        end

        tag << '>'
        tag << full_value
        tag << '</'
        tag << schema
        tag << ':'
        tag << name
        tag << '>'
      end

      private

      # Return an array with the full namespace / value
      def namespace_with_value
        @namespace_with_value ||= @value.split(/::/)
      end
    end
  end
end