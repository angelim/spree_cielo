# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_cielo'
  s.version     = '1.0.0'
  s.summary     = 'Integração do SpreeCommerce com a Administradora de Cartões Cielo'
  s.description = ''
  s.required_ruby_version = '>= 1.9.3'
  s.author            = 'Alexandre Angelim'
  s.email             = 'angelim@angelim.com.br'
  s.homepage          = 'http://github.com/angelim/spree_cielo'

  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*', 'config/**/*', 'db/**/*', 'spec/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.0.0'
  s.add_dependency 'activesupport'
  s.add_dependency 'active_attr'
  s.add_dependency 'builder'
  s.add_dependency 'delayed_job'
  s.add_dependency 'delayed_job_active_record'
  s.add_dependency 'psych', '1.3.2'
end

