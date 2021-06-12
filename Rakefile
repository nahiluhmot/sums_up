# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

# Rubocop targets rubies >= 2.5, so don't run it on lower versions.
# This allows us to test older versions on travis and feel better about lowering
# the required Ruby version to >= 2.3.
if /\A2\.[34]\./.match(RUBY_VERSION)
  task default: %i[spec]
else
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop)

  task default: %i[spec rubocop]
end
