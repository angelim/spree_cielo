module SpreeCielo
  class Engine < Rails::Engine
    engine_name 'spree_cielo'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "spree.cielo.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::Gateway::CieloGateway
    end

  end
end
