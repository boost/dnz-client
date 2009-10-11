class InvalidApiKeyError < RuntimeError
  attr_reader :api_key
  
  def initialize(api_key)
    @api_key = api_key
  end
  
  def to_s
    "Invalid API key: #{api_key}"
  end
end