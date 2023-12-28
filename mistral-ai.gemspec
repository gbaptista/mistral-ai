# frozen_string_literal: true

require_relative 'static/gem'

Gem::Specification.new do |spec|
  spec.name    = Mistral::GEM[:name]
  spec.version = Mistral::GEM[:version]
  spec.authors = [Mistral::GEM[:author]]

  spec.summary = Mistral::GEM[:summary]
  spec.description = Mistral::GEM[:description]

  spec.homepage = Mistral::GEM[:github]

  spec.license = Mistral::GEM[:license]

  spec.required_ruby_version = Gem::Requirement.new(">= #{Mistral::GEM[:ruby]}")

  spec.metadata['allowed_push_host'] = Mistral::GEM[:gem_server]

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = Mistral::GEM[:github]

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:test|spec|features)/})
    end
  end

  spec.require_paths = ['ports/dsl']

  spec.add_dependency 'event_stream_parser', '~> 1.0'
  spec.add_dependency 'faraday', '~> 2.8', '>= 2.8.1'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
