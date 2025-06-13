# Langfuse Ruby

A Ruby client library for the [Langfuse](https://langfuse.com) API - an open-source LLM observability and analytics platform.

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

## Usage

### Configuration

```ruby
require 'langfuse'

Langfuse.configure do |config|
  config.public_key = 'your_public_key'
  config.secret_key = 'your_secret_key'
  config.host = 'https://cloud.langfuse.com' # Optional, defaults to cloud.langfuse.com
end
```

### Creating Traces

```ruby
client = Langfuse.client

# Create a trace
trace = client.traces.create(
  id: 'trace-123',
  name: 'my-trace',
  user_id: 'user-456',
  input: { query: 'What is the weather like?' },
  metadata: { version: '1.0' }
)

# Get a trace
trace = client.traces.get('trace-123')

# List traces
traces = client.traces.list(limit: 10, user_id: 'user-456')

# Update a trace
client.traces.update('trace-123', 
  output: { response: 'The weather is sunny today.' }
)
```

### Creating Observations

```ruby
# Create an observation
observation = client.observations.create(
  id: 'obs-123',
  trace_id: 'trace-123',
  type: 'generation',
  name: 'llm-call',
  model: 'gpt-3.5-turbo',
  input: { messages: [{ role: 'user', content: 'Hello' }] },
  output: { content: 'Hi there!' },
  usage: { prompt_tokens: 10, completion_tokens: 5, total_tokens: 15 }
)

# Get an observation
observation = client.observations.get('obs-123')

# List observations
observations = client.observations.list(trace_id: 'trace-123')
```

### Creating Scores

```ruby
# Create a score
score = client.scores.create(
  id: 'score-123',
  trace_id: 'trace-123',
  name: 'quality',
  value: 0.8,
  comment: 'Good response quality'
)

# List scores
scores = client.scores.list(trace_id: 'trace-123')
```

### Working with Datasets

```ruby
# Create a dataset
dataset = client.datasets.create(
  name: 'my-dataset',
  description: 'Test dataset for evaluation'
)

# Add items to dataset
item = client.datasets.create_item(
  dataset_name: 'my-dataset',
  input: { question: 'What is 2+2?' },
  expected_output: { answer: '4' }
)

# List dataset items
items = client.datasets.list_items('my-dataset')
```

### Managing Prompts

```ruby
# Create a prompt
prompt = client.prompts.create(
  name: 'chat-prompt',
  prompt: 'You are a helpful assistant. Answer: {{question}}',
  config: { temperature: 0.7, max_tokens: 100 }
)

# Get a prompt
prompt = client.prompts.get('chat-prompt', version: 1)

# List prompts
prompts = client.prompts.list()
```

## Error Handling

The gem defines custom error classes:

```ruby
begin
  client.traces.create(id: 'test')
rescue Langfuse::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
rescue Langfuse::APIError => e
  puts "API error: #{e.message}"
rescue Langfuse::Error => e
  puts "General error: #{e.message}"
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/your-username/langfuse-ruby.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
