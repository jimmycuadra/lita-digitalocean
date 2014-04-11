module Lita
  module Handlers
    class Digitalocean < Handler
      class SSHKeys
        extend Forwardable

        attr_reader :client, :handler

        def_delegators :handler, :t, :do_call

        def initialize(handler, client)
          @handler = handler
          @client = client
        end

        def list(response)
          do_response = do_call { client.ssh_keys.list }

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
          key_id = response.args[2..response.args.size][0]

          if key_id
            do_response = do_call { client.ssh_keys.show(key_id) }
            key = do_response.ssh_key
            response.reply("#{key.id} (#{key.name}): #{key.ssh_pub_key}")
          else
            response.reply(t("ssh_keys.show.id_required"))
          end
        end
      end
    end
  end
end
