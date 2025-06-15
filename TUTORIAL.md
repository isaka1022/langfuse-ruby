# Langfuse Ruby SDK Tutorial

A comprehensive guide to using the Langfuse Ruby SDK for LLM observability and prompt management.

## Table of Contents

1. [Installation](#installation)
2. [Configuration](#configuration)
3. [Basic Usage](#basic-usage)
4. [Working with Traces](#working-with-traces)
5. [Working with Observations](#working-with-observations)
6. [Working with Scores](#working-with-scores)
7. [Working with Prompts](#working-with-prompts)
8. [Advanced Examples](#advanced-examples)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'langfuse-ruby'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install langfuse-ruby
```

## Configuration

Configure the Langfuse client with your API keys:

```ruby
require 'langfuse'

# Configure with your Langfuse credentials
Langfuse.configure do |config|
  config.secret_key = 'your-secret-key'
  config.public_key = 'your-public-key'
  config.base_url = 'https://cloud.langfuse.com' # Optional, defaults to cloud
end

# Create a client instance
client = Langfuse.client
```

## Basic Usage

### Quick Start Example

```ruby
#!/usr/bin/env ruby

require 'langfuse'

# Configure
Langfuse.configure do |config|
  config.secret_key = 'your-secret-key'
  config.public_key = 'your-public-key'
end

client = Langfuse.client

# Create a trace
trace = client.traces.create(
  id: "trace-#{Time.now.to_i}",
  name: 'chat-completion',
  user_id: 'user-123'
)

puts "✅ Created trace: #{trace['id']}"
```

## Working with Traces

Traces represent the top-level execution context for your LLM application.

### Creating a Trace

```ruby
trace_id = "unique-trace-id"
trace = client.traces.create(
  id: trace_id,
  name: 'conversation',
  user_id: 'user-123',
  session_id: 'session-456',
  metadata: {
    environment: 'production',
    feature: 'chat'
  },
  tags: ['important', 'customer-support']
)
```

### Updating a Trace

```ruby
updated_trace = client.traces.update(
  trace_id,
  output: { final_response: 'Thank you for using our service!' },
  metadata: { completed: true }
)
```

### Retrieving a Trace

```ruby
retrieved_trace = client.traces.get(trace_id)
```

## Working with Observations

Observations represent individual steps within a trace, such as LLM calls, tool usage, or spans.

### Creating a Generation Observation

```ruby
generation_id = "obs-#{Time.now.to_i}"
generation = client.observations.create(
  id: generation_id,
  trace_id: trace_id,
  type: 'GENERATION',
  name: 'openai-completion',
  model: 'gpt-4',
  input: {
    messages: [
      { role: 'system', content: 'You are a helpful assistant.' },
      { role: 'user', content: 'Hello, how are you?' }
    ]
  },
  output: {
    content: 'Hello! I\'m doing well, thank you for asking. How can I help you today?'
  },
  usage: {
    prompt_tokens: 20,
    completion_tokens: 15,
    total_tokens: 35
  },
  metadata: {
    temperature: 0.7,
    max_tokens: 150
  }
)
```

### Creating a Span Observation

```ruby
span = client.observations.create(
  id: "span-#{Time.now.to_i}",
  trace_id: trace_id,
  type: 'SPAN',
  name: 'data-processing',
  input: { raw_data: 'user input text' },
  output: { processed_data: 'cleaned and formatted text' },
  start_time: Time.now.iso8601,
  end_time: (Time.now + 2).iso8601
)
```

### Nested Observations

```ruby
# Parent span
parent_span = client.observations.create(
  id: "parent-#{Time.now.to_i}",
  trace_id: trace_id,
  type: 'SPAN',
  name: 'conversation-handler'
)

# Child generation
parent_span_id = "parent-#{Time.now.to_i}"
child_generation = client.observations.create(
  id: "child-#{Time.now.to_i}",
  trace_id: trace_id,
  parent_observation_id: parent_span_id,
  type: 'GENERATION',
  name: 'llm-call',
  model: 'gpt-3.5-turbo'
)
```

## Working with Scores

Scores allow you to evaluate and rate the quality of your traces and observations.

### Creating a Trace Score

```ruby
quality_score = client.scores.create(
  id: "score-#{Time.now.to_i}",
  trace_id: trace['id'],
  name: 'helpfulness',
  value: 0.9,
  comment: 'Very helpful response'
)
```

### Creating an Observation Score

```ruby
accuracy_score = client.scores.create(
  id: "obs-score-#{Time.now.to_i}",
  trace_id: trace_id,
  observation_id: generation_id,
  name: 'accuracy',
  value: 0.85,
  comment: 'Mostly accurate with minor issues'
)
```

### Different Score Types

```ruby
# Numeric score (0-1)
numeric_score = client.scores.create(
  id: "numeric-score-#{Time.now.to_i}",
  trace_id: trace_id,
  name: 'relevance',
  value: 0.75
)

# Boolean score
boolean_score = client.scores.create(
  id: "boolean-score-#{Time.now.to_i}",
  trace_id: trace_id,
  name: 'contains_pii',
  value: 0, # 0 for false, 1 for true
  comment: 'No PII detected'
)

# Categorical score
categorical_score = client.scores.create(
  id: "categorical-score-#{Time.now.to_i}",
  trace_id: trace_id,
  name: 'sentiment',
  value: nil,
  comment: 'User expressed satisfaction'
)
```

## Working with Prompts

Manage and version your prompts using the Langfuse prompt management system.

### Creating a Prompt

```ruby
prompt = client.prompts.create(
  name: 'customer-support-greeting',
  prompt: 'You are a helpful customer support assistant. Greet the user professionally and ask how you can help them today.',
  type: 'text',
  is_active: true,
  config: {
    temperature: 0.7,
    max_tokens: 150
  },
  labels: ['customer-support', 'greeting'],
  tags: ['v1', 'production']
)
```

### Creating a Chat Prompt

```ruby
chat_prompt = client.prompts.create(
  name: 'sales-assistant',
  prompt: [
    { role: 'system', content: 'You are a sales assistant. Be helpful and persuasive.' },
    { role: 'user', content: '{{user_query}}' }
  ],
  type: 'chat',
  is_active: true,
  config: {
    temperature: 0.8,
    max_tokens: 200
  }
)
```

### Retrieving a Prompt

```ruby
# Get the latest version
latest_prompt = client.prompts.get('customer-support-greeting')

# Get a specific version
versioned_prompt = client.prompts.get('customer-support-greeting', version: 2)

# Get by label
production_prompt = client.prompts.get('customer-support-greeting', label: 'production')
```

### Listing Prompts

```ruby
# List all prompts
all_prompts = client.prompts.list

# Filter by name
filtered_prompts = client.prompts.list(name: 'customer-support')

# Filter by label and tag
tagged_prompts = client.prompts.list(
  label: 'production',
  tag: 'v1',
  limit: 10
)
```

### Using Prompts in Your Application

```ruby
# Retrieve and use a prompt
prompt = client.prompts.get('customer-support-greeting')
prompt_content = prompt['prompt']

# Create a generation using the prompt
generation = client.observations.create(
  trace_id: trace_id,
  type: 'GENERATION',
  name: 'customer-greeting',
  input: { prompt: prompt_content },
  model: 'gpt-4',
  # ... other parameters
)
```

## Advanced Examples

### Complete Customer Support Flow

```ruby
require 'langfuse'

Langfuse.configure do |config|
  config.secret_key = ENV['LANGFUSE_SECRET_KEY']
  config.public_key = ENV['LANGFUSE_PUBLIC_KEY']
end

client = Langfuse.client

# 1. Create a trace for the customer interaction
trace_id = "support-#{Time.now.to_i}"
trace = client.traces.create(
  id: trace_id,
  name: 'customer-support-session',
  user_id: 'customer-456',
  session_id: 'session-789',
  metadata: {
    channel: 'web-chat',
    priority: 'high'
  }
)

# 2. Get the greeting prompt
greeting_prompt = client.prompts.get('customer-support-greeting')

# 3. Create initial greeting generation
greeting_id = "greeting-#{Time.now.to_i}"
greeting = client.observations.create(
  id: greeting_id,
  trace_id: trace_id,
  type: 'GENERATION',
  name: 'support-greeting',
  input: { prompt: greeting_prompt['prompt'] },
  output: { content: 'Hello! I\'m here to help you today. What can I assist you with?' },
  model: 'gpt-4'
)

# 4. Score the greeting
greeting_score = client.scores.create(
  id: "score-#{Time.now.to_i}",
  trace_id: trace_id,
  observation_id: greeting_id,
  name: 'politeness',
  value: 0.95,
  comment: 'Very polite and professional greeting'
)

# 5. Handle user query
user_query = "I'm having trouble with my order"

query_response = client.observations.create(
  id: "response-#{Time.now.to_i}",
  trace_id: trace_id,
  type: 'GENERATION',
  name: 'query-response',
  input: {
    messages: [
      { role: 'system', content: greeting_prompt['prompt'] },
      { role: 'user', content: user_query }
    ]
  },
  output: {
    content: 'I understand you\'re having trouble with your order. Let me help you with that. Could you please provide your order number?'
  },
  model: 'gpt-4',
  usage: {
    prompt_tokens: 45,
    completion_tokens: 25,
    total_tokens: 70
  }
)

# 6. Final trace update
client.traces.update(
  trace_id,
  output: { status: 'resolved', satisfaction: 'high' }
)

puts "✅ Customer support session completed: #{trace_id}"
```

### Batch Processing with Error Handling

```ruby
def process_batch_with_langfuse(items)
  client = Langfuse.client
  
  trace = client.traces.create(
    id: "batch-#{Time.now.to_i}",
    name: 'batch-processing',
    metadata: { batch_size: items.length }
  )
  
  results = []
  
  items.each_with_index do |item, index|
    begin
      # Create span for each item
      span = client.observations.create(
        id: "item-#{index}-#{Time.now.to_i}",
        trace_id: trace['id'],
        type: 'SPAN',
        name: "process-item-#{index}",
        input: { item_data: item }
      )
      
      # Process the item (your business logic here)
      result = process_single_item(item)
      
      # Update span with result
      client.observations.update(
        id: span['id'],
        output: { result: result, status: 'success' }
      )
      
      # Score the processing
      client.scores.create(
        id: "success-#{index}-#{Time.now.to_i}",
        trace_id: trace['id'],
        observation_id: span['id'],
        name: 'processing_success',
        value: 1
      )
      
      results << result
      
    rescue => e
      # Log error in Langfuse
      client.observations.update(
        id: span['id'],
        output: { error: e.message, status: 'failed' }
      )
      
      client.scores.create(
        id: "failed-#{index}-#{Time.now.to_i}",
        trace_id: trace['id'],
        observation_id: span['id'],
        name: 'processing_success',
        value: 0,
        comment: e.message
      )
      
      results << nil
    end
  end
  
  # Update trace with final results
  success_count = results.compact.length
  client.traces.update(
    trace['id'],
    output: {
      total_processed: items.length,
      successful: success_count,
      failed: items.length - success_count
    }
  )
  
  results
end
```

## Best Practices

1. **Use Meaningful IDs**: Generate unique, descriptive IDs for traces and observations
2. **Include Metadata**: Add relevant metadata to help with filtering and analysis
3. **Score Consistently**: Use consistent scoring criteria across your application
4. **Handle Errors**: Wrap Langfuse calls in error handling for production use
5. **Use Prompts**: Leverage prompt management for better versioning and control
6. **Nested Observations**: Use parent-child relationships to model complex workflows

## Error Handling

```ruby
begin
  trace = client.traces.create(
    id: "trace-#{Time.now.to_i}",
    name: 'example-trace'
  )
rescue Langfuse::APIError => e
  puts "Langfuse API Error: #{e.message}"
  # Handle the error appropriately
rescue => e
  puts "Unexpected error: #{e.message}"
end
```

This tutorial covers the main features of the Langfuse Ruby SDK. For more advanced usage and API details, refer to the [official Langfuse documentation](https://langfuse.com/docs).