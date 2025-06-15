require "securerandom"

module Langfuse
  module Resources
    class Scores
      def initialize(client)
        @client = client
      end

      def create(id:, name:, value:, trace_id: nil, observation_id: nil, comment: nil, source: nil, data_type: nil, config_id: nil)
        # For observation scores, we need both trace_id and observation_id
        # For trace scores, we only need trace_id
        if !observation_id && !trace_id
          raise ArgumentError, "Must provide either trace_id or observation_id"
        end

        event = {
          type: "score-create",
          id: SecureRandom.uuid,
          body: {
            id: id,
            traceId: trace_id,
            observationId: observation_id,
            name: name,
            value: value,
            comment: comment,
            source: source,
            dataType: data_type,
            configId: config_id
          }.compact
        }

        @client.ingest([event])
      end

      def get(score_id)
        @client.get("/api/public/scores/#{score_id}")
      end

      def list(page: nil, limit: nil, user_id: nil, name: nil, from_timestamp: nil, to_timestamp: nil, source: nil, operator: nil, value: nil)
        params = {
          page: page,
          limit: limit,
          userId: user_id,
          name: name,
          fromTimestamp: from_timestamp,
          toTimestamp: to_timestamp,
          source: source,
          operator: operator,
          value: value
        }.compact

        @client.get("/api/public/scores", params)
      end

      def delete(score_id)
        @client.delete("/api/public/scores/#{score_id}")
      end
    end
  end
end