# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_cielo'
  s.version     = '0.0.1'
  s.summary     = 'Integração do SpreeCommerce com a Administradora de Cartões Cielo'
  s.description = ''
  s.required_ruby_version = '>= 1.9.3'
  s.author            = 'Alexandre Angelim'
  s.email             = 'angelim@angelim.com.br'
  s.homepage          = 'http://github.com/angelim/spree_ciel'

  s.files        = Dir['CHANGELOG', 'README.md', 'LICENSE', 'lib/**/*', 'app/**/*', 'config/**/*', 'db/**/*', 'spec/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 1.0.0.rc1'
  s.add_dependency 'activesupport'
  s.add_dependency('active_attr')
  s.add_dependency('builder')
end

