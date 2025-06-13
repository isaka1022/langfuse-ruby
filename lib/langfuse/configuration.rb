module Langfuse
  class Configuration
    attr_accessor :public_key, :secret_key, :host, :debug

    def initialize
      @host = "https://cloud.langfuse.com"
      @debug = false
    end

    def host=(value)
      @host = value&.chomp("/")
    end
  end
end