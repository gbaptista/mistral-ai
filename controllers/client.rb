# frozen_string_literal: true

require 'event_stream_parser'
require 'faraday'
require 'json'

require_relative '../ports/dsl/mistral-ai/errors'

module Mistral
  module Controllers
    class Client
      DEFAULT_ADDRESS = 'https://api.mistral.ai'

      ALLOWED_REQUEST_OPTIONS = %i[timeout open_timeout read_timeout write_timeout].freeze

      def initialize(config)
        @api_key = config.dig(:credentials, :api_key)
        @server_sent_events = config.dig(:options, :server_sent_events)

        @address = if config[:credentials][:address].nil? || config[:credentials][:address].to_s.strip.empty?
                     "#{DEFAULT_ADDRESS}/"
                   else
                     "#{config[:credentials][:address].to_s.sub(%r{/$}, '')}/"
                   end

        if @api_key.nil? && @address == "#{DEFAULT_ADDRESS}/"
          raise MissingAPIKeyError, 'Missing API Key, which is required.'
        end

        @request_options = config.dig(:options, :connection, :request)

        @request_options = if @request_options.is_a?(Hash)
                             @request_options.select do |key, _|
                               ALLOWED_REQUEST_OPTIONS.include?(key)
                             end
                           else
                             {}
                           end
      end

      def chat_completions(payload, server_sent_events: nil, &callback)
        server_sent_events = false if payload[:stream] != true
        request('v1/chat/completions', payload, server_sent_events:, &callback)
      end

      def embeddings(payload, _server_sent_events: nil, &callback)
        request('v1/embeddings', payload, server_sent_events: false, &callback)
      end

      def models(_server_sent_events: nil, &callback)
        request('v1/models', nil, server_sent_events: false, request_method: 'GET', &callback)
      end

      def request(path, payload, server_sent_events: nil, request_method: 'POST', &callback)
        server_sent_events_enabled = server_sent_events.nil? ? @server_sent_events : server_sent_events
        url = "#{@address}#{path}"

        if !callback.nil? && !server_sent_events_enabled
          raise BlockWithoutServerSentEventsError,
                'You are trying to use a block without Server Sent Events (SSE) enabled.'
        end

        results = []

        method_to_call = request_method == 'POST' ? :post : :get

        response = Faraday.new(request: @request_options) do |faraday|
          faraday.response :raise_error
        end.send(method_to_call) do |request|
          request.url url
          request.headers['Content-Type'] = 'application/json'

          request.headers['Authorization'] = "Bearer #{@api_key}" unless @api_key.nil?

          request.body = payload.to_json unless payload.nil?

          if server_sent_events_enabled
            parser = EventStreamParser::Parser.new

            request.options.on_data = proc do |chunk, bytes, env|
              if env && env.status != 200
                raise_error = Faraday::Response::RaiseError.new
                raise_error.on_complete(env.merge(body: chunk))
              end

              parser.feed(chunk) do |type, data, id, reconnection_time|
                parsed_data = safe_parse_json(data)

                if parsed_data != '[DONE]'
                  result = {
                    event: safe_parse_json(data),
                    parsed: { type:, data:, id:, reconnection_time: },
                    raw: { chunk:, bytes:, env: }
                  }

                  callback.call(result[:event], result[:parsed], result[:raw]) unless callback.nil?

                  results << result

                  parsed_data['choices'].find do |candidate|
                    !candidate['finish_reason'].nil? && candidate['finish_reason'] != ''
                  end
                end
              end
            end
          end
        end

        return safe_parse_json(response.body) unless server_sent_events_enabled

        results.map { |result| result[:event] }
      rescue Faraday::ServerError => e
        raise RequestError.new(e.message, request: e, payload:)
      end

      def safe_parse_json(raw)
        raw.start_with?('{', '[') ? JSON.parse(raw) : raw
      rescue JSON::ParserError
        raw
      end
    end
  end
end
