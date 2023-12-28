# frozen_string_literal: true

require_relative '../../static/gem'
require_relative '../../controllers/client'

module Mistral
  def self.new(...)
    Controllers::Client.new(...)
  end

  def self.version
    Mistral::GEM[:version]
  end
end
