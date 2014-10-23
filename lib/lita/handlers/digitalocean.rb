module Lita
  module Handlers
    class Digitalocean < Handler
      config :client_id, type: String, required: true
      config :api_key, type: String, required: true
    end

    Lita.register_handler(Digitalocean)
  end
end
