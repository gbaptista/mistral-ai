# frozen_string_literal: true

module Mistral
  module Errors
    class MistralError < StandardError
      def initialize(message = nil)
        super(message)
      end
    end

    class MissingAPIKeyError < MistralError; end
    class BlockWithoutServerSentEventsError < MistralError; end

    class RequestError < MistralError
      attr_reader :request, :payload

      def initialize(message = nil, request: nil, payload: nil)
        @request = request
        @payload = payload

        super(message)
      end
    end
  end
end
