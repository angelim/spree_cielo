#encoding: utf-8
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/hash'
require "net/http"
require "rexml/document"
[:connection, :transaction].each { |lib| require "cielo/#{lib}" }

module Cielo

  class Production
    BASE_URL = "ecommerce.cielo.com.br"
    WS_PATH = "/servicos/ecommwsec.do"
  end

  class Test
    BASE_URL = "qasecommerce.cielo.com.br"
    WS_PATH = "/servicos/ecommwsec.do"
  end

  @@numero_afiliacao = "1001734898"
  mattr_accessor :numero_afiliacao
  @@chave_acesso="e84827130b9837473681c2787007da5914d6359947015a5cdb2b8843db0fa832"
  mattr_accessor :chave_acesso
  @@return_path = "http://localhost:3000"
  mattr_accessor :return_path
  @@parcelado_por = "loja"
  mattr_accessor :parcelado_por

  def self.setup
    yield self
  end
  class MissingArgumentError < StandardError; end
  class PaymentError < StandardError
    def initialize(errors)
      @model_errors = errors
    end
    attr_reader :model_errors
  end
end