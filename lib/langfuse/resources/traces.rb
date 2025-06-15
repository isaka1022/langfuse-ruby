require "securerandom"

module Langfuse
  module Resources
    class Traces
      def initialize(client)
        @client = client
      end

      def create(id:, name: nil, user_id: nil, session_id: nil, version: nil, release: nil, input: nil, output: nil, metadata: nil, tags: nil, timestamp: nil, public: nil)
        event = {
          type: "trace-create",
          id: SecureRandom.uuid,
          timestamp: timestamp,
          body: {
            id: id,
            name: name,
            userId: user_id,
            sessionId: session_id,
            version: version,
            release: release,
            input: input,
            output: output,
            metadata: metadata,
            tags: tags,
            public: public
          }.compact
        }

        @client.ingest([event])
      end

      def get(trace_id)
        @client.get("/api/public/traces/#{trace_id}")
      end

      def list(page: nil, limit: nil, user_id: nil, name: nil, session_id: nil, from_timestamp: nil, to_timestamp: nil, order_by: nil, tags: nil)
        params = {
          page: page,
          limit: limit,
          userId: user_id,
          name: name,
          sessionId: session_id,
          fromTimestamp: from_timestamp,
          toTimestamp: to_timestamp,
          orderBy: order_by,
          tags: tags
        }.compact

        @client.get("/api/public/traces", params)
      end

      def update(trace_id, name: nil, user_id: nil, session_id: nil, version: nil, release: nil, input: nil, output: nil, metadata: nil, tags: nil, public: nil)
        # Trace updates are done by creating a new trace-create event with the same ID
        # This will update the existing trace with new data
        event = {
          type: "trace-create",
          id: SecureRandom.uuid,
          body: {
            id: trace_id,
            name: name,
            userId: user_id,
            sessionId: session_id,
            version: version,
            release: release,
            input: input,
            output: output,
            metadata: metadata,
            tags: tags,
            public: public
          }.compact
        }

        @client.ingest([event])
      end
    end
  end
end