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

  spec.add_runtime_dependency 'api_cache', '~> 0.3'
  spec.add_runtime_dependency 'aws-sdk', '~> 2.1'
  spec.add_runtime_dependency 'json', '~> 1.8'

  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rubocop', '~> 0.32'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'simplecov', '~> 0.10'
end
