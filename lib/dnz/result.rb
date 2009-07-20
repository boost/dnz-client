require 'dnz/attributes'

module DNZ
  # A DNZ::Search result record
  class Result
    include DNZ::Attributes
    
    def initialize(doc)
      @attributes = {}

      doc.children.each do |child|
        @attributes[child.name.downcase.underscore] = child.text.to_s
      end
    end
  end
end