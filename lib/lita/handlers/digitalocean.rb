require "digital_ocean"

module Lita
  module Handlers
    class Digitalocean < Handler
      def self.default_config(config)
        config.client_id = nil
        config.api_key = nil
      end

      private

      def self.do_route(regexp, route_name, help)
        route(regexp, route_name, command: true, restrict_to: :digitalocean_admins, help: help)
      end

      public

      do_route /^do\s+regions?\s+list$/i, :regions_list, {
        t("help.regions.list_key") => t("help.regions.list_value")
      }

      do_route /^do\s+ssh\s+keys?\s+add\s+.+$/i, :ssh_keys_add, {
        t("help.ssh_keys.add_key") => t("help.ssh_keys.add_value")
      }

      do_route /^do\s+ssh\s+keys?\s+delete\s+(\d+)$/i, :ssh_keys_delete, {
        t("help.ssh_keys.delete_key") => t("help.ssh_keys.delete_value")
      }

      do_route /^do\s+ssh\s+keys?\s+edit\s+(\d+)\s+.+$/i, :ssh_keys_edit, {
        t("help.ssh_keys.edit_key") => t("help.ssh_keys.edit_value")
      }

      do_route /^do\s+ssh\s+keys?\s+list$/i, :ssh_keys_list, {
        t("help.ssh_keys.list_key") => t("help.ssh_keys.list_value")
      }

      do_route /^do\s+ssh\s+keys?\s+show\s+(\d+)$/i, :ssh_keys_show, {
        t("help.ssh_keys.show_key") => t("help.ssh_keys.show_value"),
      }

      do_route /^do\s+sizes\s+list$/, :sizes_list, {
        t("help.sizes.list_key") => t("help.sizes.list_value")
      }

      def regions_list(response)
        do_response = do_call(response) do |client|
          client.regions.list
        end or return

        messages = do_response.regions.map { |r| "ID: #{r.id}, Name: #{r.name}, Slug: #{r.slug}" }

        response.reply(*messages)
      end

      def ssh_keys_add(response)
        name, public_key = response.args[3..4]

        unless name && public_key
          return response.reply("#{t('format')}: #{t('help.ssh_keys.add_key')}")
        end

        do_response = do_call(response) do |client|
          client.ssh_keys.add(name: name, ssh_pub_key: public_key)
        end or return

        key = do_response.ssh_key
        response.reply(
          t("ssh_keys.add.created", message: "#{key.id} (#{key.name}): #{key.ssh_pub_key}")
        )
      end

      def ssh_keys_delete(response)
        key_id = response.matches[0][0]

        do_call(response) do |client|
          client.ssh_keys.delete(key_id)
        end or return

        response.reply(t("ssh_keys.delete.deleted", key_id: key_id))
      end

      def ssh_keys_edit(response)
        args = extract_named_args(response.args, :name, :public_key)

        if args[:public_key]
          args[:ssh_pub_key] = args.delete(:public_key)
        end

        do_response = do_call(response) do |client|
          client.ssh_keys.edit(response.matches[0][0], args)
        end or return

        key = do_response.ssh_key
        response.reply(
          t("ssh_keys.edit.updated", message: "#{key.id} (#{key.name}): #{key.ssh_pub_key}")
        )
      end

      def ssh_keys_list(response)
        do_response = do_call(response) do |client|
          client.ssh_keys.list
        end or return

        if do_response.ssh_keys.empty?
          response.reply(t("ssh_keys.list.empty"))
        else
          do_response.ssh_keys.each do |key|
            response.reply("#{key.id} (#{key.name})")
          end
        end
      end

      def ssh_keys_show(response)
        do_response = do_call(response) do |client|
          client.ssh_keys.show(response.matches[0][0])
        end or return

        key = do_response.ssh_key
        response.reply("#{key.id} (#{key.name}): #{key.ssh_pub_key}")
      end

      def sizes_list(response)
        do_response = do_call(response) do |client|
          client.sizes.list
        end or return

        messages = do_response.sizes.map { |s| "ID: #{s.id}, Name: #{s.name}, Slug: #{s.slug}" }

        response.reply(*messages)
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

      def do_call(response)
        unless api_key && client_id
          response.reply(t("credentials_missing"))
          return
        end

        do_response = yield client

        if do_response.status != "OK"
          response.reply(t("error", message: do_response.message))
          return
        end

        do_response
      end

      def extract_named_args(args, *keys)
        args.inject({}) do |hash, arg|
          key, value = arg.split("=", 2)

          if value
            normalized_key = key.downcase.to_sym

            if keys.include?(normalized_key)
              hash[normalized_key] = value.gsub(/\A["']|["']\Z/, "")
            end
          end

          hash
        end
      end
    end

    Lita.register_handler(Digitalocean)
  end
end
