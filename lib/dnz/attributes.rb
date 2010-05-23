module DNZ
  module Attributes
    def id
      @attributes['id']
    end

    def method_missing(symbol, *args)
      if args.empty? && @attributes.has_key?(symbol.to_s)
        @attributes[symbol.to_s]
      end
    end
  end
end