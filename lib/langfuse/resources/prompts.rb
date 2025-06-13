module Langfuse
  module Resources
    class Prompts
      def initialize(client)
        @client = client
      end

      def create(name:, prompt:, config: nil, labels: nil, tags: nil)
        data = {
          name: name,
          prompt: prompt,
          config: config,
          labels: labels,
          tags: tags
        }.compact

        @client.post("/api/public/prompts", data)
      end

      def get(prompt_name, version: nil, label: nil)
        params = {
          version: version,
          label: label
        }.compact

        path = "/api/public/prompts/#{prompt_name}"
        path += "?#{URI.encode_www_form(params)}" unless params.empty?
        
        @client.get(path)
      end

      def list(name: nil, label: nil, tag: nil, page: nil, limit: nil)
        params = {
          name: name,
          label: label,
          tag: tag,
          page: page,
          limit: limit
        }.compact

        @client.get("/api/public/prompts", params)
      end
    end
  end
end