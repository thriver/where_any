# frozen_string_literal: true

require_relative 'lib/where_any/version'

Gem::Specification.new do |spec|
  spec.name          = 'where_any'
  spec.version       = WhereAny::VERSION
  spec.authors       = ['Minty Fresh']
  spec.email         = ['7896757+mintyfresh@users.noreply.github.com']

  spec.summary       = 'Postgres ANY() and ALL() expressions for ActiveRecord.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/thriver/where_any'

  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['allowed_push_host']     = 'https://rubygems.org/'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'activerecord', '>= 5.2.0', '< 8.1'

  spec.add_development_dependency 'concurrent-ruby'
  spec.add_development_dependency 'pg', '~> 1.5'
  spec.add_development_dependency 'psych', '~> 5'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '~> 1.50.2'
  spec.add_development_dependency 'rubocop-performance', '~> 1.17.1'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.20.0'
end
