require "rash"
require "digital_ocean"

module Lita
  module Handlers
    class Digitalocean < Handler
      def self.default_config(config)
        config.client_id = nil
        config.api_key = nil
      end

      route /^do\s+ssh_?keys?\s+list\s*$/i, :ssh_keys_list, command: true
      route /^do\s+ssh_?keys?\s+show\s+(\d+)\s*$/i, :ssh_keys_show, command: true

      def ssh_keys_list(response)
        result = client.ssh_keys.list

        return response.reply(t("error")) if result.status != "OK"

        if result.ssh_keys.empty?
          response.reply(t("ssh_keys.list.empty"))
        else
          result.ssh_keys.each do |key|
            response.reply("#{key.id}: #{key.name}")
          end
        end
      end

      def ssh_keys_show(response)
        result = client.ssh_keys.show(response.matches[0][0])
        key = result.ssh_key
        response.reply("#{key.id} (#{key.name}): #{key.ssh_pub_key}")
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
