require "net/http"
require "json"
require "base64"
require "securerandom"

module Langfuse
  class Client
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def traces
      @traces ||= Resources::Traces.new(self)
    end

    def observations
      @observations ||= Resources::Observations.new(self)
    end

    def scores
      @scores ||= Resources::Scores.new(self)
    end

    def datasets
      @datasets ||= Resources::Datasets.new(self)
    end

    def prompts
      @prompts ||= Resources::Prompts.new(self)
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def post(path, body = {})
      request(:post, path, body)
    end

    def put(path, body = {})
      request(:put, path, body)
    end

    def delete(path)
      request(:delete, path)
    end

    def ingest(events)
      batch = {
        batch: events.map do |event|
          {
            id: event[:id] || SecureRandom.uuid,
            type: event[:type],
            timestamp: event[:timestamp] || Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S.%3NZ"),
            body: event[:body]
          }
        end
      }
      post("/api/public/ingestion", batch)
    end

    private

    def request(method, path, data = {})
      uri = URI("#{configuration.host}#{path}")
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      
      case method
      when :get
        uri.query = URI.encode_www_form(data) unless data.empty?
        request = Net::HTTP::Get.new(uri)
      when :post
        request = Net::HTTP::Post.new(uri)
        request.body = data.to_json
      when :put
        request = Net::HTTP::Put.new(uri)
        request.body = data.to_json
      when :delete
        request = Net::HTTP::Delete.new(uri)
      end

      request["Authorization"] = auth_header
      request["Content-Type"] = "application/json" if [:post, :put].include?(method)
      request["User-Agent"] = "langfuse-ruby/#{VERSION}"

      puts "#{method.upcase} #{uri}" if configuration.debug
      puts "Body: #{request.body}" if configuration.debug && request.body

      response = http.request(request)
      
      puts "Response: #{response.code} #{response.body}" if configuration.debug

      handle_response(response)
    end

    def auth_header
      credentials = Base64.strict_encode64("#{configuration.public_key}:#{configuration.secret_key}")
      "Basic #{credentials}"
    end

    def handle_response(response)
      case response.code.to_i
      when 200..299
        response.body.empty? ? {} : JSON.parse(response.body)
      when 401
        raise AuthenticationError, "Invalid API credentials"
      when 400..499
        error_message = JSON.parse(response.body)["error"] rescue "Client error"
        raise APIError, "#{response.code}: #{error_message}"
      when 500..599
        raise APIError, "Server error: #{response.code}"
      else
        raise APIError, "Unexpected response: #{response.code}"
      end
    end
  end
end