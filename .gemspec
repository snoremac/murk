Gem::Specification.new do |spec|
  spec.name        = 'cloudseed'
  spec.version     = '0.1.0'
  spec.summary     = 'CloudSeed'
  spec.description = 'CloudSeed - Parameterization and environmental partitioning for AWS CloudFormation'
  spec.authors     = ['Cam Smith']
  spec.licenses    = ['MIT']
  spec.homepage    = 'https://github.com/snoremac/cloudseed'
  spec.files       = Dir['lib/**/*', 'bin/cloudseed']
  spec.bindir      = 'bin'
  spec.executables = ['cloudseed']

  spec.add_runtime_dependency 'api_cache'
  spec.add_runtime_dependency 'aws-sdk', '~> 2.1'
  spec.add_runtime_dependency 'json'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
end
