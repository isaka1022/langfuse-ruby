# langfuse-ruby

> **Unofficial Ruby client** for the [Langfuse](https://langfuse.com) API — an open-source LLM observability and analytics platform.
>
> Note: Official and community-maintained gems also exist on RubyGems ([langfuse-rb](https://rubygems.org/gems/langfuse-rb), [langfuse-ruby](https://rubygems.org/gems/langfuse-ruby)). This repository is a personal implementation built to explore the Langfuse API surface in Ruby.

---

## Overview

This gem provides a lightweight Ruby interface to the Langfuse REST API. It supports the core observability primitives:

- **Traces** — top-level execution contexts for LLM requests
- **Observations** — individual steps within a trace (generations, spans, events)
- **Scores** — numeric or categorical evaluations attached to traces or observations
- **Prompts** — versioned prompt management (text and chat formats)
- **Datasets** — evaluation datasets and dataset runs

Events are sent via the `/api/public/ingestion` batch endpoint. Direct REST endpoints are used for reads.

## Requirements

- Ruby >= 2.7.0

## Installation

Add to your Gemfile:

```ruby
gem 'langfuse-ruby', git: 'https://github.com/isaka1022/langfuse-ruby'
```

Then run:

```bash
bundle install
```

## Configuration

```ruby
require 'langfuse'

Langfuse.configure do |config|
  config.public_key = ENV['LANGFUSE_PUBLIC_KEY']
  config.secret_key = ENV['LANGFUSE_SECRET_KEY']
  config.host       = 'https://cloud.langfuse.com' # optional; default shown
  config.debug      = false                         # set true to log HTTP traffic
end

client = Langfuse.client
```

Self-hosted Langfuse: set `config.host` to your instance URL.

## Usage

### Traces

```ruby
# Create a trace
client.traces.create(
  id:       'trace-001',
  name:     'chat-completion',
  user_id:  'user-42',
  input:    { query: 'What is the capital of France?' },
  metadata: { env: 'production' },
  tags:     ['chat', 'v2']
)

# Retrieve
trace = client.traces.get('trace-001')

# List (supports page, limit, user_id, name, session_id, from_timestamp, tags)
traces = client.traces.list(limit: 20, user_id: 'user-42')

# Update (re-ingests a trace-create event with the same ID)
client.traces.update('trace-001', output: { answer: 'Paris' })
```

### Observations

Observations represent individual steps — LLM calls (`GENERATION`), intermediate steps (`SPAN`), or discrete events (`EVENT`).

```ruby
# Record an LLM generation
client.observations.create(
  id:       'obs-001',
  trace_id: 'trace-001',
  type:     'GENERATION',
  name:     'openai-call',
  model:    'gpt-4o',
  input:    { messages: [{ role: 'user', content: 'What is the capital of France?' }] },
  output:   { content: 'Paris' },
  usage:    { prompt_tokens: 12, completion_tokens: 3, total_tokens: 15 }
)

# Retrieve / list
obs   = client.observations.get('obs-001')
list  = client.observations.list(trace_id: 'trace-001', type: 'GENERATION')

# Update
client.observations.update('obs-001', metadata: { latency_ms: 430 })
```

Supported `type` values: `GENERATION`, `SPAN`, `EVENT`.

Nest observations with `parent_observation_id` to model complex multi-step pipelines.

### Scores

```ruby
# Score a trace
client.scores.create(
  id:       'score-001',
  trace_id: 'trace-001',
  name:     'helpfulness',
  value:    0.9,
  comment:  'Clear and accurate answer'
)

# Score a specific observation
client.scores.create(
  id:             'score-002',
  trace_id:       'trace-001',
  observation_id: 'obs-001',
  name:           'accuracy',
  value:          1.0
)

# List / delete
client.scores.list(trace_id: 'trace-001')
client.scores.delete('score-001')
```

### Prompts

```ruby
# Create a versioned prompt
client.prompts.create(
  name:      'support-greeter',
  prompt:    'You are a helpful support agent. Greet {{user_name}} and ask how you can help.',
  type:      'text',       # or 'chat'
  is_active: true,
  config:    { temperature: 0.7 }
)

# Retrieve (latest, by version, or by label)
prompt = client.prompts.get('support-greeter')
prompt = client.prompts.get('support-greeter', version: 2)
prompt = client.prompts.get('support-greeter', label: 'production')

# List
client.prompts.list(label: 'production', limit: 10)
```

### Datasets

```ruby
# Create a dataset
client.datasets.create(name: 'qa-eval', description: 'Q&A evaluation set')

# Add items
client.datasets.create_item(
  dataset_name:    'qa-eval',
  input:           { question: 'What is 2 + 2?' },
  expected_output: { answer: '4' }
)

# List items and runs
client.datasets.list_items('qa-eval', limit: 50)

# Dataset runs
client.datasets.create_run(dataset_name: 'qa-eval', name: 'run-20260611')
client.datasets.list_runs('qa-eval')
```

### Error Handling

```ruby
begin
  client.traces.create(id: 'trace-x', name: 'test')
rescue Langfuse::AuthenticationError => e
  puts "Bad credentials: #{e.message}"
rescue Langfuse::APIError => e
  puts "API error: #{e.message}"
rescue Langfuse::Error => e
  puts "Client error: #{e.message}"
end
```

## API Coverage

| Resource     | create | get | list | update | delete |
|-------------|:------:|:---:|:----:|:------:|:------:|
| Traces       | ✓      | ✓   | ✓    | ✓      |        |
| Observations | ✓      | ✓   | ✓    | ✓ *    |        |
| Scores       | ✓      | ✓   | ✓    |        | ✓      |
| Prompts      | ✓      | ✓   | ✓    |        |        |
| Datasets     | ✓      | ✓   | ✓    |        |        |
| Dataset Items| ✓      | ✓   | ✓    |        |        |
| Dataset Runs | ✓      | ✓   | ✓    |        |        |

\* `observations.update` calls `PUT /api/public/observations/:id`, which is not part of the official Langfuse API. It will be reworked to use ingestion-based span/generation updates in a future release (see Roadmap).

## Roadmap

### Now
- **OTEL ingestion mode** — migrate from the deprecated `POST /api/public/ingestion` batch endpoint to OTLP/HTTP (`/api/public/otel/v1/traces`); required to keep the gem functional long-term
- **`environment` field support** — pass environment to trace/observation bodies per the current Langfuse API
- **Type-specific observation helpers** — `trace.generation()` / `trace.span()` / `trace.event()` convenience methods

### Next
- **Async batch flush** — background thread with `Mutex` to buffer and flush events non-blocking
- **Sessions API** — create and retrieve sessions
- **Score Configs API** — manage score configuration definitions
- **Comments API** — attach and list comments on traces and observations
- **Gem rename and RubyGems publish prep** — rename to `langfuse-client` (or similar available name) and publish to RubyGems.org

### Later
- **Rails Railtie** — auto-instrument via `ActiveSupport::Notifications` with zero config
- **Models API** — retrieve model definitions from Langfuse
- **`PromptTemplate` class** — typed wrapper with client-side variable interpolation
- **Annotation Queues API** — support for annotation queue management

## Development

```bash
bundle install
bundle exec rake spec
```

Tests use [RSpec](https://rspec.info/) and [WebMock](https://github.com/bblimke/webmock) for HTTP stubbing.

## License

MIT License — see [LICENSE](LICENSE) for details.
