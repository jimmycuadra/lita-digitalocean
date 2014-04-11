module Lita
  module Handlers
    class Digitalocean < Handler
      class SSHKeys
        extend Forwardable

        attr_reader :client, :handler

        def_delegators :handler, :t

        def initialize(handler, client)
          @handler = handler
          @client = client
        end

        def list(response)
          do_response = client.ssh_keys.list

          return response.reply(t("error")) if do_response.status != "OK"

          if do_response.ssh_keys.empty?
            response.reply(t("ssh_keys.list.empty"))
          else
            do_response.ssh_keys.each do |key|
              response.reply("#{key.id} (#{key.name})")
            end
          end
        end

        def show(response)
          do_response = client.ssh_keys.show(response.args[2..-1])
          key = do_response.ssh_key
          response.reply("#{key.id} (#{key.name}): #{key.ssh_pub_key}")
        end
      end
    end
  end
end
