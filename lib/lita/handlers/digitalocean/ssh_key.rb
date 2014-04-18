module Lita
  module Handlers
    class Digitalocean < Handler
      class SSHKey < Base
        do_route /^do\s+ssh\s+keys?\s+add\s+.+$/i, :add, {
          t("help.ssh_keys.add_key") => t("help.ssh_keys.add_value")
        }

        do_route /^do\s+ssh\s+keys?\s+delete\s+(\d+)$/i, :delete, {
          t("help.ssh_keys.delete_key") => t("help.ssh_keys.delete_value")
        }

        do_route /^do\s+ssh\s+keys?\s+edit\s+(\d+)\s+.+$/i, :edit, {
          t("help.ssh_keys.edit_key") => t("help.ssh_keys.edit_value")
        }

        do_route /^do\s+ssh\s+keys?\s+list$/i, :list, {
          t("help.ssh_keys.list_key") => t("help.ssh_keys.list_value")
        }

        do_route /^do\s+ssh\s+keys?\s+show\s+(\d+)$/i, :show, {
          t("help.ssh_keys.show_key") => t("help.ssh_keys.show_value"),
        }

        def add(response)
          name, public_key = response.args[3..4]

          unless name && public_key
            return response.reply("#{t('format')}: #{t('help.ssh_keys.add_key')}")
          end

          do_response = do_call(response) do |client|
            client.ssh_keys.add(name: name, ssh_pub_key: public_key)
          end or return

          response.reply(t("ssh_keys.add.created", do_response[:ssh_key]))
        end

        def delete(response)
          key_id = response.matches[0][0]

          do_call(response) do |client|
            client.ssh_keys.delete(key_id)
          end or return

          response.reply(t("ssh_keys.delete.deleted", key_id: key_id))
        end

        def edit(response)
          args = extract_named_args(response.args, :name, :public_key)

          if args[:public_key]
            args[:ssh_pub_key] = args.delete(:public_key)
          end

          do_response = do_call(response) do |client|
            client.ssh_keys.edit(response.matches[0][0], args)
          end or return

          response.reply(t("ssh_keys.edit.updated", do_response[:ssh_key]))
        end

        def list(response)
          do_response = do_call(response) do |client|
            client.ssh_keys.list
          end or return

          if do_response[:ssh_keys].empty?
            response.reply(t("ssh_keys.list.empty"))
          else
            do_response[:ssh_keys].each do |key|
              response.reply("#{key[:id]} (#{key[:name]})")
            end
          end
        end

        def show(response)
          do_response = do_call(response) do |client|
            client.ssh_keys.show(response.matches[0][0])
          end or return

          key = do_response[:ssh_key]
          response.reply("#{key[:id]} (#{key[:name]}): #{key[:ssh_pub_key]}")
        end
      end

      Lita.register_handler(SSHKey)
    end
  end
end
