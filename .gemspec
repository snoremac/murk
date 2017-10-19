Gem::Specification.new do |spec|
  spec.name        = 'murk'
  spec.version     = '0.4.0'
  spec.summary     = 'Murk'
  spec.description = 'Murk - Parameterization and environmental partitioning for AWS CloudFormation'
  spec.authors     = ['Cam Smith']
  spec.licenses    = ['MIT']
  spec.homepage    = 'https://github.com/snoremac/murk'
  spec.files       = Dir['lib/**/*', 'bin/murk']
  spec.bindir      = 'bin'
  spec.executables = ['murk']

  spec.add_runtime_dependency 'api_cache', '~> 0.3'
  spec.add_runtime_dependency 'aws-sdk', '~> 2.6'
  spec.add_runtime_dependency 'json', '~> 1.8'
  spec.add_runtime_dependency 'clamp', '~> 1.0'

  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rubocop', '~> 0.32'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'simplecov', '~> 0.10'
end
