module SpreeCielo
  class Engine < Rails::Engine
    engine_name 'spree_cielo'

    config.autoload_paths += %W(#{config.root}/lib)

    initializer "spree.register.cielo_regular_payment_method", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::CieloRegularMethod
    end
    
    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end
    config.to_prepare &method(:activate).to_proc
    
    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

  end
end
