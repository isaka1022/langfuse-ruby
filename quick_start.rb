#!/usr/bin/env ruby

require_relative 'lib/langfuse'

# Configure (replace with your actual keys)
Langfuse.configure do |config|
  config.secret_key = 'YOUR_SECRET_KEY'
  config.public_key = 'YOUR_PUBLIC_KEY'
end

client = Langfuse.client

# 1. Create a trace
trace = client.traces.create(
  id: "trace-#{Time.now.to_i}",
  name: 'chat-completion',
  user_id: 'user-123'
)

# 2. Add an LLM observation
observation = client.observations.create(
  id: "obs-#{Time.now.to_i}",
  trace_id: trace['id'],
  type: 'generation',
  name: 'openai-call',
  model: 'gpt-4',
  input: { messages: [{ role: 'user', content: 'Hello!' }] },
  output: { content: 'Hi there!' },
  usage: { prompt_tokens: 5, completion_tokens: 3, total_tokens: 8 }
)

# 3. Add a quality score
score = client.scores.create(
  id: "score-#{Time.now.to_i}",
  trace_id: trace['id'],
  name: 'helpfulness',
  value: 0.9
)

puts "✅ Created trace: #{trace['id']}"
puts "✅ Created observation: #{observation['id']}"  
puts "✅ Created score: #{score['id']}"
