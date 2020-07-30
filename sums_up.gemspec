# frozen_string_literal: true

require_relative 'lib/sums_up/version'

Gem::Specification.new do |spec|
  spec.name = 'sums_up'
  spec.version = SumsUp::VERSION
  spec.authors = ['Tom Hulihan']
  spec.email = ['hulihan.tom159@gmail.com']

  spec.summary = 'Sum types for Ruby'
  spec.homepage = 'https://github.com/nahiluhmot/sums_up'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`
      .split("\x0")
      .reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_development_dependency 'pry', '~> 0.13'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.88.0'
end
