require "spec_helper"

RSpec.describe Langfuse::Client do
  let(:configuration) do
    config = Langfuse::Configuration.new
    config.public_key = "test_public_key"
    config.secret_key = "test_secret_key"
    config.host = "https://api.test.com"
    config
  end

  let(:client) { described_class.new(configuration) }

  describe "#get" do
    it "makes GET request with correct headers" do
      stub_request(:get, "https://api.test.com/test")
        .with(
          headers: {
            "Authorization" => "Basic #{Base64.strict_encode64('test_public_key:test_secret_key')}",
            "User-Agent" => "langfuse-ruby/#{Langfuse::VERSION}"
          }
        )
        .to_return(status: 200, body: '{"success": true}')

      result = client.get("/test")
      expect(result).to eq({"success" => true})
    end
  end

  describe "#post" do
    it "makes POST request with JSON body" do
      stub_request(:post, "https://api.test.com/test")
        .with(
          body: '{"data":"value"}',
          headers: {
            "Authorization" => "Basic #{Base64.strict_encode64('test_public_key:test_secret_key')}",
            "Content-Type" => "application/json",
            "User-Agent" => "langfuse-ruby/#{Langfuse::VERSION}"
          }
        )
        .to_return(status: 201, body: '{"created": true}')

      result = client.post("/test", {data: "value"})
      expect(result).to eq({"created" => true})
    end
  end

  describe "error handling" do
    it "raises AuthenticationError for 401" do
      stub_request(:get, "https://api.test.com/test")
        .to_return(status: 401)

      expect { client.get("/test") }.to raise_error(Langfuse::AuthenticationError)
    end

    it "raises APIError for 4xx errors" do
      stub_request(:get, "https://api.test.com/test")
        .to_return(status: 400, body: '{"error": "Bad request"}')

      expect { client.get("/test") }.to raise_error(Langfuse::APIError, /400/)
    end

    it "raises APIError for 5xx errors" do
      stub_request(:get, "https://api.test.com/test")
        .to_return(status: 500)

      expect { client.get("/test") }.to raise_error(Langfuse::APIError, /Server error/)
    end
  end
end