require "spec_helper"

RSpec.describe Langfuse::Resources::Traces do
  let(:client) { instance_double(Langfuse::Client) }
  let(:traces) { described_class.new(client) }

  describe "#create" do
    it "ingests a trace-create event with required parameters" do
      expect(client).to receive(:ingest) do |events|
        expect(events.length).to eq(1)
        event = events.first
        expect(event[:type]).to eq("trace-create")
        expect(event[:body]).to eq({ id: "trace-123" })
      end.and_return({ "successes" => [{ "id" => "trace-123" }] })

      traces.create(id: "trace-123")
    end

    it "ingests a trace-create event with optional parameters" do
      expect(client).to receive(:ingest) do |events|
        expect(events.length).to eq(1)
        event = events.first
        expect(event[:type]).to eq("trace-create")
        expect(event[:body]).to include(
          id: "trace-123",
          name: "test-trace",
          userId: "user-456",
          sessionId: "session-789",
          input: { "query" => "test" },
          metadata: { "version" => "1.0" }
        )
      end.and_return({ "successes" => [{ "id" => "trace-123" }] })

      traces.create(
        id: "trace-123",
        name: "test-trace",
        user_id: "user-456",
        session_id: "session-789",
        input: { "query" => "test" },
        metadata: { "version" => "1.0" }
      )
    end
  end

  describe "#get" do
    it "retrieves a trace by ID" do
      expect(client).to receive(:get)
        .with("/api/public/traces/trace-123")
        .and_return({ "id" => "trace-123" })

      result = traces.get("trace-123")
      expect(result).to eq({ "id" => "trace-123" })
    end
  end

  describe "#list" do
    it "lists traces with no parameters" do
      expect(client).to receive(:get)
        .with("/api/public/traces", {})
        .and_return({ "data" => [] })

      result = traces.list
      expect(result).to eq({ "data" => [] })
    end

    it "lists traces with parameters" do
      expected_params = {
        page: 1,
        limit: 10,
        userId: "user-123"
      }

      expect(client).to receive(:get)
        .with("/api/public/traces", expected_params)
        .and_return({ "data" => [] })

      result = traces.list(page: 1, limit: 10, user_id: "user-123")
      expect(result).to eq({ "data" => [] })
    end
  end

  describe "#update" do
    it "ingests a trace-create event to update the trace" do
      expect(client).to receive(:ingest) do |events|
        expect(events.length).to eq(1)
        event = events.first
        expect(event[:type]).to eq("trace-create")
        expect(event[:body]).to include(
          id: "trace-123",
          name: "updated-trace",
          metadata: { "version" => "2.0" }
        )
      end.and_return({ "successes" => [{ "id" => "trace-123" }] })

      traces.update("trace-123", name: "updated-trace", metadata: { "version" => "2.0" })
    end
  end
end
