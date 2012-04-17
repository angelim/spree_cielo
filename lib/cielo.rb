#encoding: utf-8
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/hash'
require "net/http"
require "rexml/document"
[:connection, :transaction].each { |lib| require "cielo/#{lib}" }

module Cielo

  class Production
    BASE_URL = "ecommerce.cbmp.com.br"
    WS_PATH = "/servicos/ecommwsec.do"
  end

  class Test
    BASE_URL = "qasecommerce.cielo.com.br"
    WS_PATH = "/servicos/ecommwsec.do"
  end

  @@numero_afiliacao = "1006993069"
  mattr_accessor :numero_afiliacao
  @@chave_acesso="25fbb99741c739dd84d7b06ec78c9bac718838630f30b112d033ce2e621b34f3"
  mattr_accessor :chave_acesso
  @@return_path = "http://localhost:3000"
  mattr_accessor :return_path

  def self.setup
    yield self
  end
  class MissingArgumentError < StandardError; end
end