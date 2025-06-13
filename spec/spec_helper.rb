require "bundler/setup"
require "langfuse"
require "webmock/rspec"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    WebMock.reset!
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  config.after(:each) do
    Langfuse.instance_variable_set(:@configuration, nil)
    Langfuse.instance_variable_set(:@client, nil)
  end
end