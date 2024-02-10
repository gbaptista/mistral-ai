# Mistral AI

A Ruby gem for interacting with [Mistral AI](https://mistral.ai)'s large language models.

![The image features a graphic that merges a red ruby gem with a robotic face to symbolize the integration of a Ruby software library with Mistral AI's technology. The ruby has a reflective white top facet and the robot face includes two orange eyes, reflecting the Mistral AI logo's color. The design is modern and set against a dark background to emphasize the gem and robotic features.](https://raw.githubusercontent.com/gbaptista/assets/main/mistral-ai/ruby-mistral-ai.png)

> _This Gem is designed to provide low-level access to Mistral, enabling people to build abstractions on top of it. If you are interested in more high-level abstractions or more user-friendly tools, you may want to consider [Nano Bots](https://github.com/icebaker/ruby-nano-bots) 💎 🤖._

## TL;DR and Quick Start

```ruby
gem 'mistral-ai', '~> 1.2.0'
```

```ruby
require 'mistral-ai'

client = Mistral.new(
  credentials: { api_key: ENV['MISTRAL_API_KEY'] },
  options: { server_sent_events: true }
)

result = client.chat_completions(
  { model: 'mistral-medium',
    messages: [{ role: 'user', content: 'hi!' }] }
)
```

Result:
```ruby
{ 'id' => 'cmpl-74fb544d49d04195a4182342936af43b',
  'object' => 'chat.completion',
  'created' => 1_703_792_737,
  'model' => 'mistral-medium',
  'choices' =>
  [{ 'index' => 0,
     'message' =>
     { 'role' => 'assistant',
       'content' =>
       "Hello! How can I assist you today? If you have any questions or need help with something, feel free to ask. I'm here to help.\n" \
         "\n" \
         "If you're not sure where to start, you can ask me about a specific topic, such as a programming language, a scientific concept, or a current event. You can also ask me to tell you a joke, generate a random number, or provide a fun fact.\n" \
         "\n" \
         "I'm a large language model trained by Mistral AI, so I can understand and generate human-like text on a wide range of topics. I can also perform tasks such as summarizing text, translating between languages, and answering questions about a given text. I look forward to helping you!" },
     'finish_reason' => 'stop' }],
  'usage' => { 'prompt_tokens' => 10, 'total_tokens' => 166, 'completion_tokens' => 156 } }
```

## Index

- [TL;DR and Quick Start](#tldr-and-quick-start)
- [Index](#index)
- [Setup](#setup)
  - [Installing](#installing)
  - [Credentials](#credentials)
- [Usage](#usage)
  - [Client](#client)
    - [Custom Address](#custom-address)
  - [Methods](#methods)
    - [chat_completions](#chat_completions)
      - [Without Streaming Events](#without-streaming-events)
      - [Receiving Stream Events](#receiving-stream-events)
    - [embeddings](#embeddings)
    - [models](#models)
  - [Streaming and Server-Sent Events (SSE)](#streaming-and-server-sent-events-sse)
    - [Server-Sent Events (SSE) Hang](#server-sent-events-sse-hang)
  - [System Messages](#system-messages)
  - [Back-and-Forth Conversations](#back-and-forth-conversations)
  - [New Functionalities and APIs](#new-functionalities-and-apis)
  - [Request Options](#request-options)
    - [Adapter](#adapter)
    - [Timeout](#timeout)
  - [Error Handling](#error-handling)
    - [Rescuing](#rescuing)
    - [For Short](#for-short)
    - [Errors](#errors)
- [Development](#development)
  - [Purpose](#purpose)
  - [Publish to RubyGems](#publish-to-rubygems)
  - [Updating the README](#updating-the-readme)
- [Resources and References](#resources-and-references)
- [Disclaimer](#disclaimer)

## Setup

### Installing

```sh
gem install mistral-ai -v 1.2.0
```

```sh
gem 'mistral-ai', '~> 1.2.0'
```

### Credentials

You can obtain your API key from the [Mistral AI Platform](https://console.mistral.ai).

## Usage

### Client

Ensure that you have an [API Key](#credentials) for authentication.

Create a new client:
```ruby
require 'mistral-ai'

client = Mistral.new(
  credentials: { api_key: ENV['MISTRAL_API_KEY'] },
  options: { server_sent_events: true }
)
```

#### Custom Address

You can use a custom address:

```ruby
require 'mistral-ai'

client = Mistral.new(
  credentials: {
    address: 'https://api.mistral.ai',
    api_key: ENV['MISTRAL_API_KEY']
  },
  options: { server_sent_events: true }
)
```

### Methods

#### chat_completions

##### Without Streaming Events

```ruby
result = client.chat_completions(
  { model: 'mistral-medium',
    messages: [{ role: 'user', content: 'hi!' }] }
)
```

Result:
```ruby
{ 'id' => 'cmpl-74fb544d49d04195a4182342936af43b',
  'object' => 'chat.completion',
  'created' => 1_703_792_737,
  'model' => 'mistral-medium',
  'choices' =>
  [{ 'index' => 0,
     'message' =>
     { 'role' => 'assistant',
       'content' =>
       "Hello! How can I assist you today? If you have any questions or need help with something, feel free to ask. I'm here to help.\n" \
         "\n" \
         "If you're not sure where to start, you can ask me about a specific topic, such as a programming language, a scientific concept, or a current event. You can also ask me to tell you a joke, generate a random number, or provide a fun fact.\n" \
         "\n" \
         "I'm a large language model trained by Mistral AI, so I can understand and generate human-like text on a wide range of topics. I can also perform tasks such as summarizing text, translating between languages, and answering questions about a given text. I look forward to helping you!" },
     'finish_reason' => 'stop' }],
  'usage' => { 'prompt_tokens' => 10, 'total_tokens' => 166, 'completion_tokens' => 156 } }
```

##### Receiving Stream Events

Ensure that you have enabled [Server-Sent Events](#streaming-and-server-sent-events-sse) before using blocks for streaming. You also need to add `stream: true` in your payload:

```ruby
client.chat_completions(
  { model: 'mistral-medium',
    stream: true,
    messages: [{ role: 'user', content: 'hi!' }] }
) do |event, parsed, raw|
  puts event
end
```

Event:
```ruby
{ 'id' => 'cmpl-011e6223d8414df4840293b98e0b18ca',
  'object' => 'chat.completion.chunk',
  'created' => 1_703_796_464,
  'model' => 'mistral-medium',
  'choices' => [
    { 'index' => 0, 'delta' => { 'role' => nil, 'content' => 'Hello' },
      'finish_reason' => nil }
  ] }
```

You can get all the receive events at once as an array:
```ruby
result = client.chat_completions(
  { model: 'mistral-medium',
    stream: true,
    messages: [{ role: 'user', content: 'hi!' }] }
)
```

Result:
```ruby
[{ 'id' => 'cmpl-20bc384332d749958251e11427aeeb42',
   'model' => 'mistral-medium',
   'choices' => [{ 'index' => 0, 'delta' => { 'role' => 'assistant' }, 'finish_reason' => nil }] },
 { 'id' => 'cmpl-20bc384332d749958251e11427aeeb42',
   'object' => 'chat.completion.chunk',
   'created' => 1_703_796_630,
   'model' => 'mistral-medium',
   'choices' => [{ 'index' => 0, 'delta' => { 'role' => nil, 'content' => 'Hello! How can I' },
                   'finish_reason' => nil }] },
 { 'id' => 'cmpl-20bc384332d749958251e11427aeeb42',
   'object' => 'chat.completion.chunk',
   'created' => 1_703_796_630,
   'model' => 'mistral-medium',
   'choices' => [{ 'index' => 0, 'delta' => { 'role' => nil, 'content' => ' assist you today?' },
                   'finish_reason' => nil }] },
 # ...
 { 'id' => 'cmpl-20bc384332d749958251e11427aeeb42',
   'object' => 'chat.completion.chunk',
   'created' => 1_703_796_630,
   'model' => 'mistral-medium',
   'choices' => [{ 'index' => 0, 'delta' => { 'role' => nil, 'content' => '' },
                   'finish_reason' => 'stop' }] }]
```

You can mix both as well:
```ruby
result = client.chat_completions(
  { model: 'mistral-medium',
    stream: true,
    messages: [{ role: 'user', content: 'hi!' }] }
) do |event, parsed, raw|
  puts event
end
```

#### embeddings

```ruby
result = client.embeddings(
  { model: 'mistral-embed',
    input: [
      'Embed this sentence.',
      'As well as this one.'
    ] }
)
```

Result:
```ruby
{ 'id' => 'embd-03f43eaec35744a3bab6f2ca83418555',
  'object' => 'list',
  'data' =>
  [{ 'object' => 'embedding',
     'embedding' =>
     [-0.0165863037109375,
      0.07012939453125,
      # ...
      0.00428009033203125,
      -0.036895751953125],
     'index' => 0 },
   { 'object' => 'embedding',
     'embedding' =>
     [-0.0234222412109375,
      0.039337158203125,
      # ...
      0.00044846534729003906,
      -0.01065826416015625],
     'index' => 1 }],
  'model' => 'mistral-embed',
  'usage' => { 'prompt_tokens' => 15, 'total_tokens' => 15, 'completion_tokens' => 0 } }

```

#### models

```ruby
result = client.models
```

Result:
```ruby
{ 'object' => 'list',
  'data' =>
  [{ 'id' => 'mistral-medium',
     'object' => 'model',
     'created' => 1_703_855_983,
     'owned_by' => 'mistralai',
     'root' => nil,
     'parent' => nil,
     'permission' =>
     [{ 'id' => 'modelperm-30...',
        'object' => 'model_permission',
        'created' => 1_703_855_983,
        'allow_create_engine' => false,
        'allow_sampling' => true,
        'allow_logprobs' => false,
        'allow_search_indices' => false,
        'allow_view' => true,
        'allow_fine_tuning' => false,
        'organization' => '*',
        'group' => nil,
        'is_blocking' => false }] },
   { 'id' => 'mistral-small',
     'object' => 'model',
     'created' => 1_703_855_983,
     'owned_by' => 'mistralai',
     # ...
     },
   # ...
   ] }
```

### Streaming and Server-Sent Events (SSE)

[Server-Sent Events (SSE)](https://en.wikipedia.org/wiki/Server-sent_events) is a technology that allows certain endpoints to offer streaming capabilities, such as creating the impression that "the model is typing along with you," rather than delivering the entire answer all at once.

You can set up the client to use Server-Sent Events (SSE) for all supported endpoints:
```ruby
client = Mistral.new(
  credentials: { api_key: ENV['MISTRAL_API_KEY'] },
  options: { server_sent_events: true }
)
```

Or, you can decide on a request basis:
```ruby
client.chat_completions(
  { model: 'mistral-medium',
    stream: true,
    messages: [{ role: 'user', content: 'hi!' }] },
  server_sent_events: true
) do |event, parsed, raw|
  puts event
end
```

With Server-Sent Events (SSE) enabled, you can use a block to receive partial results via events. This feature is particularly useful for methods that offer streaming capabilities, such as `chat_completions`: [Receiving Stream Events](#receiving-stream-events)

#### Server-Sent Events (SSE) Hang

Method calls will _hang_ until the server-sent events finish, so even without providing a block, you can obtain the final results of the received events: [Receiving Stream Events](#receiving-stream-events)

### System Messages

System messages influence how the model answers:

```ruby
result = client.chat_completions(
  { model: 'mistral-medium',
    messages: [
      { role: 'system', content: 'Only answer strictly using JSON.' },
      { role: 'user', content: 'Calculate 1 + 1.' }
    ] }
)
```

Result:
```ruby
{ 'id' => 'cmpl-0c6fee44022841728e435ac91416d211',
  'object' => 'chat.completion',
  'created' => 1_703_794_201,
  'model' => 'mistral-medium',
  'choices' => [{
    'index' => 0,
    'message' => { 'role' => 'assistant', 'content' => '{"result": 2}' },
    'finish_reason' => 'stop'
  }],
  'usage' => { 'prompt_tokens' => 24, 'total_tokens' => 30, 'completion_tokens' => 6 } }

```

### Back-and-Forth Conversations

To maintain a back-and-forth conversation, you need to append the received responses and build a history for your requests:

```rb
result = client.chat_completions(
  { model: 'mistral-medium',
    messages: [
      { role: 'user',
        content: 'Hi! My name is Purple.' },
      { role: 'assistant',
        content: "Hello Purple! It's nice to meet you. How can I help you today?" },
      { role: 'user', content: "What's my name?" }
    ] }
)
```

Result:
```ruby
{ 'id' => 'cmpl-cbc4a8db84b347738840e34e46388f1f',
  'object' => 'chat.completion',
  'created' => 1_703_793_492,
  'model' => 'mistral-medium',
  'choices' =>
  [{ 'index' => 0,
     'message' => {
       'role' => 'assistant',
       'content' => 'Your name is Purple, as you introduced yourself earlier. Is there anything else I can help you with?'
     },
     'finish_reason' => 'stop' }],
  'usage' => { 'prompt_tokens' => 49, 'total_tokens' => 71, 'completion_tokens' => 22 } }
```

### New Functionalities and APIs

Mistral may launch a new endpoint that we haven't covered in the Gem yet. If that's the case, you may still be able to use it through the `request` method. For example, `chat_completions` is just a wrapper for `v1/chat/completions`, which you can call directly like this:

```ruby
result = client.request(
  'v1/chat/completions',
  { model: 'mistral-medium',
    messages: [{ role: 'user', content: 'hi!' }] },
  request_method: 'POST', server_sent_events: true
)
```

### Request Options

#### Adapter

The gem uses [Faraday](https://github.com/lostisland/faraday) with the [Typhoeus](https://github.com/typhoeus/typhoeus) adapter by default.

You can use a different adapter if you want:

```ruby
require 'faraday/net_http'

client = Mistral.new(
  credentials: { api_key: ENV['MISTRAL_API_KEY'] },
  options: { connection: { adapter: :net_http } }
)
```

#### Timeout

You can set the maximum number of seconds to wait for the request to complete with the `timeout` option:

```ruby
client = Mistral.new(
  credentials: { api_key: ENV['MISTRAL_API_KEY'] },
  options: { connection: { request: { timeout: 5 } } }
)
```

You can also have more fine-grained control over [Faraday's Request Options](https://lostisland.github.io/faraday/#/customization/request-options?id=request-options) if you prefer:

```ruby
client = Mistral.new(
  credentials: { api_key: ENV['MISTRAL_API_KEY'] },
  options: {
    connection: {
      request: {
        timeout: 5,
        open_timeout: 5,
        read_timeout: 5,
        write_timeout: 5
      }
    }
  }
)
```

### Error Handling

#### Rescuing

```ruby
require 'mistral-ai'

begin
  client.chat_completions(
    { model: 'mistral-medium',
      messages: [{ role: 'user', content: 'hi!' }] }
  )
rescue Mistral::Errors::MistralError => error
  puts error.class # Mistral::Errors::RequestError
  puts error.message # 'the server responded with status 500'

  puts error.payload
  # { model: 'mistral-medium',
  #   messages: [{ role: 'user', content: 'hi!' }] },
  #   ...
  # }

  puts error.request
  # #<Faraday::ServerError response={:status=>500, :headers...
end
```

#### For Short

```ruby
require 'mistral-ai/errors'

begin
  client.chat_completions(
    { model: 'mistral-medium',
      messages: [{ role: 'user', content: 'hi!' }] }
  )
rescue MistralError => error
  puts error.class # Mistral::Errors::RequestError
end
```

#### Errors

```ruby
MistralError

MissingAPIKeyError
BlockWithoutServerSentEventsError

RequestError
```

## Development

```bash
bundle
rubocop -A

bundle exec ruby spec/tasks/run-client.rb
```

### Purpose

This Gem is designed to provide low-level access to Mistral, enabling people to build abstractions on top of it. If you are interested in more high-level abstractions or more user-friendly tools, you may want to consider [Nano Bots](https://github.com/icebaker/ruby-nano-bots) 💎 🤖.

### Publish to RubyGems

```bash
gem build mistral-ai.gemspec

gem signin

gem push mistral-ai-1.2.0.gem
```

### Updating the README

Install [Babashka](https://babashka.org):

```sh
curl -s https://raw.githubusercontent.com/babashka/babashka/master/install | sudo bash
```

Update the `template.md` file and then:

```sh
bb tasks/generate-readme.clj
```

Trick for automatically updating the `README.md` when `template.md` changes:

```sh
sudo pacman -S inotify-tools # Arch / Manjaro
sudo apt-get install inotify-tools # Debian / Ubuntu / Raspberry Pi OS
sudo dnf install inotify-tools # Fedora / CentOS / RHEL

while inotifywait -e modify template.md; do bb tasks/generate-readme.clj; done
```

Trick for Markdown Live Preview:
```sh
pip install -U markdown_live_preview

mlp README.md -p 8076
```

## Resources and References

These resources and references may be useful throughout your learning process.

- [Mistral AI Official Website](https://mistral.ai)
- [Mistral AI Documentation](https://docs.mistral.ai)
- [Mistral AI API Documentation](https://docs.mistral.ai/api/)

## Disclaimer

This is not an official Mistral project, nor is it affiliated with Mistral in any way.

This software is distributed under the [MIT License](https://github.com/gbaptista/mistral-ai/blob/main/LICENSE). This license includes a disclaimer of warranty. Moreover, the authors assume no responsibility for any damage or costs that may result from using this project. Use the Mistral AI Ruby Gem at your own risk.
