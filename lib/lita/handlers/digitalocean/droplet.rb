module Lita
  module Handlers
    class Digitalocean < Handler
      module Droplet
        def self.included(base)
          base.instance_eval do
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
          end
        end
      end
    end
  end
end
