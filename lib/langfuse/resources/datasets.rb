module Langfuse
  module Resources
    class Datasets
      def initialize(client)
        @client = client
      end

      def create(name:, description: nil, metadata: nil)
        data = {
          name: name,
          description: description,
          metadata: metadata
        }.compact

        @client.post("/api/public/datasets", data)
      end

      def get(dataset_name)
        @client.get("/api/public/datasets/#{dataset_name}")
      end

      def list(page: nil, limit: nil)
        params = {
          page: page,
          limit: limit
        }.compact

        @client.get("/api/public/datasets", params)
      end

      def create_item(dataset_name:, id: nil, input: nil, expected_output: nil, metadata: nil, source_trace_id: nil, source_observation_id: nil, status: nil)
        data = {
          id: id,
          input: input,
          expectedOutput: expected_output,
          metadata: metadata,
          sourceTraceId: source_trace_id,
          sourceObservationId: source_observation_id,
          status: status
        }.compact

        @client.post("/api/public/datasets/#{dataset_name}/items", data)
      end

      def get_item(dataset_name, item_id)
        @client.get("/api/public/datasets/#{dataset_name}/items/#{item_id}")
      end

      def list_items(dataset_name, page: nil, limit: nil)
        params = {
          page: page,
          limit: limit
        }.compact

        @client.get("/api/public/datasets/#{dataset_name}/items", params)
      end

      def create_run(dataset_name:, name:, description: nil, metadata: nil)
        data = {
          name: name,
          description: description,
          metadata: metadata
        }.compact

        @client.post("/api/public/datasets/#{dataset_name}/runs", data)
      end

      def get_run(dataset_name, run_name)
        @client.get("/api/public/datasets/#{dataset_name}/runs/#{run_name}")
      end

      def list_runs(dataset_name, page: nil, limit: nil)
        params = {
          page: page,
          limit: limit
        }.compact

        @client.get("/api/public/datasets/#{dataset_name}/runs", params)
      end
    end
  end
end