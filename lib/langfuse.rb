require_relative "langfuse/version"
require_relative "langfuse/client"
require_relative "langfuse/configuration"
require_relative "langfuse/resources/traces"
require_relative "langfuse/resources/observations"
require_relative "langfuse/resources/scores"
require_relative "langfuse/resources/datasets"
require_relative "langfuse/resources/prompts"

module Langfuse
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class APIError < Error; end

  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.client
    @client ||= Client.new(configuration)
  end
end