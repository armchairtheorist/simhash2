require File.expand_path('../lib/simhash2/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = 'simhash2'
  spec.version       = Simhash::VERSION
  spec.authors       = ['Jonathan Wong']
  spec.email         = ['jonathan@armchairtheorist.com']
  spec.summary       = 'A rewrite of the \'simhash\' gem, which is an implementation of Moses Charikar\'s simhashes in Ruby.'
  spec.homepage      = 'http://github.com/armchairtheorist/simhash'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {spec}/*`.split("\n")
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec', '~> 0'
  spec.add_development_dependency 'rake', '~> 0'
end
