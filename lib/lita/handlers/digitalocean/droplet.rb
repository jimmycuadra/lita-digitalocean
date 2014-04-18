module Lita
  module Handlers
    class Digitalocean < Handler
      class Droplet < Base
        do_route /^do\s+droplets?\s+create(?:\s+[^\s]+){4}/i, :create, {
          t("help.droplets.create_key") => t("help.droplets.create_value")
        }

        do_route /^do\s+droplets?\s+delete\s+\d+/i, :delete, {
          t("help.droplets.delete_key") => t("help.droplets.delete_value")
        }

        do_route /^do\s+droplets?\s+list$/i, :list, {
          t("help.droplets.list_key") => t("help.droplets.list_value")
        }

        do_route /^do\s+droplets?\s+password\s+reset\s+\d+$/i, :password_reset, {
          t("help.droplets.password_reset_key") => t("help.droplets.password_reset_value")
        }

        do_route /^do\s+droplets?\s+power\s+cycle\s+\d+$/i, :power_cycle, {
          t("help.droplets.power_cycle_key") => t("help.droplets.power_cycle_value")
        }

        do_route /^do\s+droplets?\s+power\s+off\s+\d+$/i, :power_off, {
          t("help.droplets.power_off_key") => t("help.droplets.power_off_value")
        }

        do_route /^do\s+droplets?\s+power\s+on\s+\d+$/i, :power_on, {
          t("help.droplets.power_on_key") => t("help.droplets.power_on_value")
        }

        do_route /^do\s+droplets?\s+reboot\s+\d+$/i, :reboot, {
          t("help.droplets.reboot_key") => t("help.droplets.reboot_value")
        }

        do_route /^do\s+droplets?\s+rebuild(?:\s+\d+){2}$/i, :rebuild, {
          t("help.droplets.rebuild_key") => t("help.droplets.rebuild_value")
        }

        do_route /^do\s+droplets?\s+resize\s+\d+\s+[^\s]+$/i, :resize, {
          t("help.droplets.resize_key") => t("help.droplets.resize_value")
        }

        do_route /^do\s+droplets?\s+restore(?:\s+\d+){2}$/i, :restore, {
          t("help.droplets.restore_key") => t("help.droplets.restore_value")
        }

        do_route /^do\s+droplets?\s+show\s+\d+$/i, :show, {
          t("help.droplets.show_key") => t("help.droplets.show_value")
        }

        do_route /^do\s+droplets?\s+shut\s*down\s+\d+$/i, :shutdown, {
          t("help.droplets.shutdown_key") => t("help.droplets.shutdown_value")
        }

        do_route /^do\s+droplets?\s+snapshot\s+\d+/i, :snapshot, {
          t("help.droplets.snapshot_key") => t("help.droplets.snapshot_value")
        }

        def create(response)
          name, size, image, region, *args = response.args[2..response.args.size]
          kwargs = extract_named_args(args, :ssh_key_ids, :private_networking, :backups_enabled)

          numeric = /^\d+$/

          size_key = size =~ numeric ? :size_id : :size_slug
          image_key = image =~ numeric ? :image_id : :image_slug
          region_key = region =~ numeric ? :region_id : :region_slug

          options = {
            name: name,
            size_key => size,
            image_key => image,
            region_key => region
          }.merge(kwargs)

          do_response = do_call(response) do |client|
            client.droplets.create(options)
          end or return

          response.reply(t("droplets.create.created", do_response[:droplet]))
        end

        def delete(response)
          kwargs = extract_named_args(response.args, :scrub)
          id = response.args[2]
          options = {}
          options[:scrub_data] = true if kwargs[:scrub]
          do_response = do_call(response) do |client|
            client.droplets.delete(id, options)
          end or return

          response.reply(t("droplets.delete.deleted", id: id))
        end

        def list(response)
          do_response = do_call(response) do |client|
            client.droplets.list
          end or return

          messages = do_response[:droplets].map { |droplet| t("droplets.list.detail", droplet) }

          response.reply(*messages)
        end

        def password_reset(response)
          id = response.args[3]
          do_response = do_call(response) do |client|
            client.droplets.password_reset(id)
          end or return

          response.reply(t("droplets.password_reset.reset", id: id))
        end

        def power_cycle(response)
          id = response.args[3]
          do_response = do_call(response) do |client|
            client.droplets.power_cycle(response.args[3])
          end or return

          response.reply(t("droplets.power_cycle.cycled", id: id))
        end

        def power_off(response)
          id = response.args[3]
          do_response = do_call(response) do |client|
            client.droplets.power_off(response.args[3])
          end or return

          response.reply(t("droplets.power_off.powered_off", id: id))
        end

        def power_on(response)
          id = response.args[3]
          do_response = do_call(response) do |client|
            client.droplets.power_on(response.args[3])
          end or return

          response.reply(t("droplets.power_on.powered_on", id: id))
        end

        def reboot(response)
          id = response.args[2]
          do_response = do_call(response) do |client|
            client.droplets.reboot(response.args[2])
          end or return

          response.reply(t("droplets.reboot.rebooted", id: id))
        end

        def rebuild(response)
          id, image_id = response.args[2..3]
          do_response = do_call(response) do |client|
            client.droplets.rebuild(id, image_id: image_id)
          end or return

          response.reply(t("droplets.rebuild.rebuilt", id: id))
        end
      end

      Lita.register_handler(Droplet)
    end
  end
end
