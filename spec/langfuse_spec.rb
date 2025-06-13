require "spec_helper"

RSpec.describe Langfuse do
  it "has a version number" do
    expect(Langfuse::VERSION).not_to be nil
  end

  describe ".configure" do
    it "yields configuration" do
      expect { |b| Langfuse.configure(&b) }.to yield_with_args(Langfuse.configuration)
    end

    it "allows setting configuration values" do
      Langfuse.configure do |config|
        config.public_key = "test_public_key"
        config.secret_key = "test_secret_key"
        config.host = "https://test.example.com"
      end

      expect(Langfuse.configuration.public_key).to eq("test_public_key")
      expect(Langfuse.configuration.secret_key).to eq("test_secret_key")
      expect(Langfuse.configuration.host).to eq("https://test.example.com")
    end
  end

  describe ".client" do
    it "returns a client instance" do
      expect(Langfuse.client).to be_a(Langfuse::Client)
    end

    it "reuses the same client instance" do
      expect(Langfuse.client).to be(Langfuse.client)
    end
  end
end