#encoding: utf-8
module Cielo
  module Transaction
    class Base
      include ActiveAttr::Model
      BANDEIRAS = %w(visa mastercard elo diners discovery)
      INDICADORES = [0, 1, 2, 9]
      IDIOMAS = %w(PT EN ES)
    
      attribute :dados_ec_numero, type: String, default: lambda{ Cielo.numero_afiliacao }
      attribute :dados_ec_chave, type: String, default: lambda{ Cielo.chave_acesso }
      validates :dados_ec_numero, :format => {:with => /\d./}, :length => {:minimum => 1, :maximum => 20}, :presence => true
      validates :dados_ec_chave, :length => {:minimum => 1, :maximum => 100}, :presence => true

      attribute :dados_portador_numero, type: Integer
      attribute :dados_portador_validade, type: Date
      attribute :dados_portador_indicador, type: Integer
      attribute :dados_portador_codigo_seguranca, type: Integer
      attribute :dados_portador_nome_portador, type: String
      validates :dados_portador_numero, :format => {:with => /\d./}, :length => {:minimum => 16, :maximum => 16}, :presence => true, :if => :enviar_portador?
      validates :dados_portador_validade, :presence => true, :if => :enviar_portador?
      validates :dados_portador_indicador, :inclusion => {:in => INDICADORES}, :if => :enviar_portador?
      validates :dados_portador_codigo_seguranca, :presence => true, :if => :indicador_presente?, :if => :enviar_portador?
      validates :dados_portador_nome_portador, :length => { :maximum => 20 }, :if => :enviar_portador?
        
      attribute :dados_pedido_numero, type: String
      attribute :dados_pedido_valor, type: Float
      attribute :dados_pedido_moeda, type: Integer, default: 986
      attribute :dados_pedido_data_hora, type: DateTime, default: lambda { DateTime.now }
      attribute :dados_pedido_descricao, type: String
      attribute :dados_pedido_idioma, type: String, default: "PT"
      validates :dados_pedido_numero, :presence => true, :length => { :maximum => 20 }
      validates :dados_pedido_valor, :dados_pedido_moeda, :dados_pedido_data_hora, :presence => true
      validates :dados_pedido_descricao, :length => { :maximum => 1024 }
      validates :dados_pedido_idioma, :inclusion => {:in => IDIOMAS, :allow_blank => true}
    
      attribute :forma_pagamento_bandeira, type: String, default: BANDEIRAS.first
      attribute :forma_pagamento_produto, type: Integer, default: 1
      attribute :forma_pagamento_parcelas, type: Integer, default: 1
      validates :forma_pagamento_bandeira, :inclusion => {:in => BANDEIRAS}, :presence => true
      validates :forma_pagamento_parcelas, :presence => true
  
      attribute :autorizar, type: Integer, default: 3
      attribute :capturar, type: String, default: "false"
      attribute :cielo_environment, type: String, default: "Test"
      validates :cielo_environment, :inclusion => {:in => %w(Test Production)}
      validates :capturar, :inclusion => {:in => %w(true false)}
      validates :autorizar, :presence => true    
      
      attr_accessor :response
      attr_accessor :parsed_response
      attr_accessor :message
      attr_accessor :cielo_environment
      
      def initialize
        super
        @connection = Cielo::Connection.new(cielo_environment)
      end

      def indicador_presente?
        dados_portador_indicador == 1
      end
      
      def format_name(name)
        name.gsub("_", "-")
      end

      def attributes_hash(attr_names)
        attr_names.inject({}){|acc, name| acc[format_name(name)] = send(name); acc }
      end
      
      def save!
        return false if !valid?
        self.message = xml_builder("requisicao-transacao") do |xml|
          if enviar_portador?
            xml.tag!("dados-portador") do
              xml.numero dados_portador_numero
              xml.validade I18n.l(dados_portador_validade, :format => :cielo)
              xml.indicador dados_portador_indicador
              xml.tag!("codigo-seguranca", dados_portador_codigo_seguranca) if dados_portador_codigo_seguranca.present?
              xml.tag!("nome-portador", dados_portador_nome_portador) if dados_portador_nome_portador.present?
            end
          end
          
          xml.tag!("dados-pedido") do
            xml.numero dados_pedido_numero
            xml.valor (dados_pedido_valor*100).to_i
            xml.moeda dados_pedido_moeda
            xml.tag!("data-hora", I18n.l(dados_pedido_data_hora, :format => :cielo))
            xml.descricao dados_pedido_descricao if dados_pedido_descricao.present?
            xml.idioma dados_pedido_idioma
          end
          
          xml.tag!("forma-pagamento") do
            xml.bandeira forma_pagamento_bandeira
            xml.produto forma_pagamento_produto
            xml.parcelas forma_pagamento_parcelas
          end

          attributes_hash(root_attributes).each do |name, value|
            xml.tag!(name, value) if value.present?
          end
        end.target!
        make_request!
      end
    
      def verify!(cielo_tid)
        return nil unless cielo_tid
        self.message = xml_builder("requisicao-consulta", :before) do |xml|
          xml.tid "#{cielo_tid}"
        end.target!
      
        make_request!
      end
    
      def catch!(cielo_tid)
        return nil unless cielo_tid
        self.message = xml_builder("requisicao-captura", :before) do |xml|
          xml.tid "#{cielo_tid}"
        end.target!
        make_request!
      end

      def xml_builder(group_name, target=:after, &block)
        xml = Builder::XmlMarkup.new
        xml.instruct! :xml, :version=>"1.0", :encoding=>"ISO-8859-1"
        xml.tag!(group_name, :id => "#{Time.now.to_i}", :versao => "1.1.0") do
          block.call(xml) if target == :before
          xml.tag!("dados-ec") do
            xml.numero dados_ec_numero
            xml.chave dados_ec_chave
          end
          block.call(xml) if target == :after
        end
        xml
      end
    
      def make_request!
        self.response, self.parsed_response = nil, nil
        params = { :mensagem => message }
      
        self.response = @connection.request! params
      end
    
      def parse_response
        case response
        when Net::HTTPSuccess
          document = REXML::Document.new(response.body)
          self.parsed_response = parse_elements(document.elements)
        else
          self.errors[:base] = {:erro => { :codigo => "000", :mensagem => "Impossível contactar o servidor"}}
        end
      end
      
      def parse_elements(elements)
        map={}
        elements.each do |element|
          element_map = {}
          element_map = element.text if element.elements.empty? && element.attributes.empty?
          element_map.merge!("value" => element.text) if element.elements.empty? && !element.attributes.empty?
          element_map.merge!(parse_elements(element.elements)) unless element.elements.empty?
          map.merge!(element.name => element_map)
        end
        map.symbolize_keys
      end
    end
  end
end