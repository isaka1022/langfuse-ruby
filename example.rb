#!/usr/bin/env ruby

require_relative 'lib/langfuse'

# Configure the client
Langfuse.configure do |config|
  config.public_key = ENV['LANGFUSE_PUBLIC_KEY'] || 'your_public_key'
  config.secret_key = ENV['LANGFUSE_SECRET_KEY'] || 'your_secret_key'
  config.host = ENV['LANGFUSE_HOST'] || 'https://cloud.langfuse.com'
  config.debug = true # Enable debug logging
end

client = Langfuse.client

begin
  # Create a trace
  puts "Creating a trace..."
  trace = client.traces.create(
    id: "trace-#{Time.now.to_i}",
    name: 'example-trace',
    user_id: 'demo-user',
    input: { query: 'What is the capital of France?' },
    metadata: { 
      version: '1.0',
      source: 'ruby-example'
    }
  )
  puts "✅ Trace created: #{trace['id']}"

  # Create an observation
  puts "\nCreating an observation..."
  observation = client.observations.create(
    id: "obs-#{Time.now.to_i}",
    trace_id: trace['id'],
    type: 'generation',
    name: 'llm-response',
    model: 'gpt-3.5-turbo',
    input: { 
      messages: [
        { role: 'user', content: 'What is the capital of France?' }
      ]
    },
    output: { 
      content: 'The capital of France is Paris.'
    },
    usage: {
      prompt_tokens: 12,
      completion_tokens: 8,
      total_tokens: 20
    }
  )
  puts "✅ Observation created: #{observation['id']}"

  # Create a score
  puts "\nCreating a score..."
  score = client.scores.create(
    id: "score-#{Time.now.to_i}",
    trace_id: trace['id'],
    name: 'accuracy',
    value: 1.0,
    comment: 'Correct answer provided'
  )
  puts "✅ Score created: #{score['id']}"

  # List recent traces
  puts "\nListing recent traces..."
  traces = client.traces.list(limit: 5)
  puts "📋 Found #{traces['data']&.length || 0} traces"

rescue Langfuse::AuthenticationError => e
  puts "❌ Authentication failed: #{e.message}"
  puts "Make sure to set LANGFUSE_PUBLIC_KEY and LANGFUSE_SECRET_KEY environment variables"
rescue Langfuse::APIError => e
  puts "❌ API error: #{e.message}"
rescue => e
  puts "❌ Unexpected error: #{e.message}"
  puts e.backtrace
end