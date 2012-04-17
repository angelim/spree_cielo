module SpreeCielo
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      
      desc "Cria o initializer da cielo na app rails"
      
      def copy_initializer
        template "cielo.rb", "config/initializers/cielo.rb"
      end
      
      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=spree_cielo'
      end

      def run_migrations
        res = ask "Would you like to run the migrations now? [Y/n]"
        if res == "" || res.downcase == "y"
          run 'bundle exec rake db:migrate'
        else
          puts "Skiping rake db:migrate, don't forget to run it!"
        end
      end
      
    end
  end
end