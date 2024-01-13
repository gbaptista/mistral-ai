# frozen_string_literal: true

require 'dotenv/load'

require 'mistral-ai'

begin
  client = Mistral.new(
    credentials: { api_key: nil },
    options: { server_sent_events: true }
  )

  client.chat_completions(
    { model: 'mistral-tiny',
      messages: [{ role: 'user', content: 'hi!' }] }
  )
rescue StandardError => e
  raise "Unexpected error: #{e.class}" unless e.instance_of?(Mistral::Errors::MissingAPIKeyError)
end

client = Mistral.new(
  credentials: { api_key: ENV.fetch('MISTRAL_API_KEY', nil) },
  options: { server_sent_events: true }
)

result = client.chat_completions(
  { model: 'mistral-tiny',
    stream: true,
    messages: [{ role: 'user', content: 'hi!' }] }
) do |event, _parsed, _raw|
  print event['choices'][0]['delta']['content']
end

puts "\n#{'-' * 20}"

puts result.map { |event| event['choices'][0]['delta']['content'] }.join
