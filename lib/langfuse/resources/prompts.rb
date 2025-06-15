module Langfuse
  module Resources
    class Prompts
      def initialize(client)
        @client = client
      end

      def create(name:, prompt:, type: 'text', is_active: true, config: nil, labels: nil, tags: nil)
        data = {
          name: name,
          prompt: prompt,
          type: type,
          isActive: is_active,
          config: config,
          labels: labels,
          tags: tags
        }.compact

        @client.post("/api/public/v2/prompts", data)
      end

      def get(prompt_name, version: nil, label: nil)
        params = {
          version: version,
          label: label
        }.compact

        path = "/api/public/v2/prompts/#{URI.encode_www_form_component(prompt_name)}"
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

        @client.get("/api/public/v2/prompts", params)
      end

      def compile(prompt_name, variables: {}, version: nil, label: nil)
        data = {
          prompt_name: prompt_name,
          variables: variables,
          version: version,
          label: label
        }.compact

        @client.post("/api/public/v2/prompts/compile", data)
      end
    end
  end
end
