module Lita
  module Handlers
    class Digitalocean < Handler
      def self.default_config(config)
        config.client_id = nil
        config.api_key = nil
      end
    end

    Lita.register_handler(Digitalocean)
  end
end
