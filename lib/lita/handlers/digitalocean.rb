require "rash"
require "digital_ocean"

require_relative "digitalocean/ssh_keys"

module Lita
  module Handlers
    class Digitalocean < Handler
      class APIError < StandardError; end

      SUBMODULES = {
        ssh_keys: SSHKeys
      }

      def self.default_config(config)
        config.client_id = nil
        config.api_key = nil
      end

      route /^(?:do|digital\s*ocean)/i, :dispatch, command: true

      def dispatch(response)
        submodule_name, subcommand_name, *_args = response.args
        submodule_class = SUBMODULES[submodule_name.downcase.to_sym]

        if submodule_class
          submodule = submodule_class.new(self, client)

          subcommand = subcommand_name.downcase.to_sym

          if submodule.respond_to?(subcommand)
            begin
              submodule.public_send(subcommand, response)
            rescue APIError => e
              response.reply(t("error", message: e.message))
            end
          end
        end
      end

      def do_call
        do_response = yield

        if do_response.status != "OK"
          raise APIError.new(do_response.message)
        end

        do_response
      end

      private

      def api_key
        config.api_key
      end

      def client
        @client ||= ::DigitalOcean::API.new(client_id: client_id, api_key: api_key)
      end

      def client_id
        config.client_id
      end

      def config
        Lita.config.handlers.digitalocean
      end
    end

    Lita.register_handler(Digitalocean)
  end
end
