require "securerandom"

module Langfuse
  module Resources
    class Observations
      def initialize(client)
        @client = client
      end

      def create(id:, trace_id:, type:, name: nil, start_time: nil, end_time: nil, completion_start_time: nil, model: nil, model_parameters: nil, input: nil, output: nil, usage: nil, metadata: nil, level: nil, status_message: nil, parent_observation_id: nil, version: nil)
        event = {
          type: "observation-create",
          id: SecureRandom.uuid,
          body: {
            id: id,
            traceId: trace_id,
            type: type,
            name: name,
            startTime: start_time,
            endTime: end_time,
            completionStartTime: completion_start_time,
            model: model,
            modelParameters: model_parameters,
            input: input,
            output: output,
            usage: usage,
            metadata: metadata,
            level: level,
            statusMessage: status_message,
            parentObservationId: parent_observation_id,
            version: version
          }.compact
        }

        @client.ingest([event])
      end

      def get(observation_id)
        @client.get("/api/public/observations/#{observation_id}")
      end

      def list(page: nil, limit: nil, name: nil, user_id: nil, trace_id: nil, from_start_time: nil, to_start_time: nil, type: nil)
        params = {
          page: page,
          limit: limit,
          name: name,
          userId: user_id,
          traceId: trace_id,
          fromStartTime: from_start_time,
          toStartTime: to_start_time,
          type: type
        }.compact

        @client.get("/api/public/observations", params)
      end

      def update(observation_id, type: nil, name: nil, start_time: nil, end_time: nil, completion_start_time: nil, model: nil, model_parameters: nil, input: nil, output: nil, usage: nil, metadata: nil, level: nil, status_message: nil, version: nil)
        data = {
          type: type,
          name: name,
          startTime: start_time,
          endTime: end_time,
          completionStartTime: completion_start_time,
          model: model,
          modelParameters: model_parameters,
          input: input,
          output: output,
          usage: usage,
          metadata: metadata,
          level: level,
          statusMessage: status_message,
          version: version
        }.compact

        @client.put("/api/public/observations/#{observation_id}", data)
      end
    end
  end
end