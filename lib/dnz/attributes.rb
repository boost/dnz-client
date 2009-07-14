module DNZ
  module Attributes
    def method_missing(symbol, *args)
      if args.empty? && @attributes.has_key?(symbol.to_s)
        @attributes[symbol.to_s]
      end
    end
  end
end