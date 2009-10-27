module DNZ
  module Record
    class MetadataArray < Array
      def find_by_schema(schema)
        MetadataArray.new(select{|m| m.schema == schema})
      end

      def find_by_name(name)
        MetadataArray.new(select{|m| m.name == name})
      end

      def find_by_namespace(namespace)
        MetadataArray.new(select{|m| m.in_namespace?(namespace)})
      end

      def find_by_user_contributed(user_contributed)
        MetadataArray.new(select{|m| m.user_contributed? == user_contributed })
      end
    end
  end
end