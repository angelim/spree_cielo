# Spree Pagseguro

Uma extensão do [Spree](http://spreecommerce.com) para permitir pagamentos utilizando a Cielo.

## Instalação

Adicione spree ao gemfile da sua aplicação, e também:

    gem "spree_cielo"

Rode a task de instalação:

    rails generate spree_cielo:install
	
## Configuração
	
Após feita a instalação e migração, acesse a administração do spree, vá em Configuração -> Métodos de Pagamento e adicione um novo método selecionando `Spree::Gateway::Cielo`.

## Adaptação

Caso queira enviar um e-mail ao usuário quando a compra for aprovada pelo cielo, sobrescreva a máquina de estados do `Spree::Payment` em sua aplicação para fazer o envio do e-mail (a classe PaymentMailer não existe, e precisa ser criada por você):
	
	Spree::Payment.class_eval do
	  state_machine do
	    after_transition :to => 'completed', :do => :send_confirmation!
	  end
  
	  def send_confirmation!
	    PaymentMailer.confirm_email(self.order).deliver
	  end
	end
    
    
## TODO

* Adicionar Testes

## Contribuindo

Caso queira contribuir, faça um fork desta gem no [github](https://github.com/heavenstudio/spree_pag_seguro), corriga o bug/ adicione a feature desejada e faça um merge request.

## Sobre

Desenvolvida por [Alexandre Angelim](mailto:angelim@angelim.com.br)
