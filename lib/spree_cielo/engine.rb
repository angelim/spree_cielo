module SpreeCielo
  class Engine < Rails::Engine
    engine_name 'spree_cielo'

    config.autoload_paths += %W(#{config.root}/lib)

    initializer "spree.register.cielo_regular_payment_method", after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::CieloRegularMethod
    end
    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

  end
end
