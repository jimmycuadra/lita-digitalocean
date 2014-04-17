module Lita
  module Handlers
    class Digitalocean < Handler
      class Droplet < Base
        do_route(
          /^do\s+droplets?\s+create(?:\s+[^\s]+){4}/i,
          :droplets_create,
          {
            t("help.droplets.create_key") => t("help.droplets.create_value")
          }
        )

        do_route /^do\s+droplets?\s+delete\s+\d+/i, :droplets_delete, {
          t("help.droplets.delete_key") => t("help.droplets.delete_value")
        }

        do_route /^do\s+droplets?\s+list$/i, :droplets_list, {
          t("help.droplets.list_key") => t("help.droplets.list_value")
        }

        do_route /^do\s+droplets?\s+password\s+reset\s+\d+$/i, :droplets_password_reset, {
          t("help.droplets.password_reset_key") => t("help.droplets.password_reset_value")
        }

        do_route /^do\s+droplets?\s+power\s+cycle\s+\d+$/i, :droplets_power_cycle, {
          t("help.droplets.power_cycle_key") => t("help.droplets.power_cycle_value")
        }

        do_route /^do\s+droplets?\s+power\s+off\s+\d+$/i, :droplets_power_off, {
          t("help.droplets.power_off_key") => t("help.droplets.power_off_value")
        }

        do_route /^do\s+droplets?\s+power\s+on\s+\d+$/i, :droplets_power_on, {
          t("help.droplets.power_on_key") => t("help.droplets.power_on_value")
        }

        do_route /^do\s+droplets?\s+reboot\s+\d+$/i, :droplets_reboot, {
          t("help.droplets.reboot_key") => t("help.droplets.reboot_value")
        }

        do_route /^do\s+droplets?\s+rebuild(?:\s+\d+){2}$/i, :droplets_rebuild, {
          t("help.droplets.rebuild_key") => t("help.droplets.rebuild_value")
        }

        do_route /^do\s+droplets?\s+resize\s+\d+\s+[^\s]+$/i, :droplets_resize, {
          t("help.droplets.resize_key") => t("help.droplets.resize_value")
        }

        do_route /^do\s+droplets?\s+restore(?:\s+\d+){2}$/i, :droplets_restore, {
          t("help.droplets.restore_key") => t("help.droplets.restore_value")
        }

        do_route /^do\s+droplets?\s+show\s+\d+$/i, :droplets_show, {
          t("help.droplets.show_key") => t("help.droplets.show_value")
        }

        do_route /^do\s+droplets?\s+shut\s*down\s+\d+$/i, :droplets_shutdown, {
          t("help.droplets.shutdown_key") => t("help.droplets.shutdown_value")
        }

        do_route /^do\s+droplets?\s+snapshot\s+\d+/i, :droplets_snapshot, {
          t("help.droplets.snapshot_key") => t("help.droplets.snapshot_value")
        }

        def droplets_create(response)
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
          end

          response.reply(t("droplets.create.created", do_response[:droplet]))
        end

        def droplets_delete(response)
          kwargs = extract_named_args(response.args, :scrub)
          options = {}
          options[:scrub_data] = true if kwargs[:scrub]
          do_response = do_call(response) do |client|
            client.droplets.delete(response.args[2], options)
          end

          response.reply(t("droplets.delete.deleted", do_response[:droplet]))
        end
      end

      Lita.register_handler(Droplet)
    end
  end
end
