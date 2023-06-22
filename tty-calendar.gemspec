# frozen_string_literal: true

require_relative 'lib/tty/calendar/version'

Gem::Specification.new do |spec|
  spec.name = 'tty-calendar'
  spec.version = TTY::Calendar::VERSION
  spec.authors = ['Michael Cordell']
  spec.email = ['mike@mikecordell.com']

  spec.summary = 'Terminal calendar'
  spec.description = 'Utility for manipulating a calendar in the command line'
  spec.homepage = 'https://github.com/mcordell/tty-calendar'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/mcordell/tty-calendar'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(bin/ test/ spec/ features/ .git .circleci appveyor Gemfile))
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'tty-box', '>= 0.7.0'
  spec.add_dependency 'tty-cursor', '>= 0.7.0'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
