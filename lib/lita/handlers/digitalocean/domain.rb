module Lita
  module Handlers
    class Digitalocean < Handler
      class Domain < Base
        do_route /^do\s+domains?\s+create\s+[^\s]+\s+[^\s]+$/i, :create, {
          t("help.domains.create_key") => t("help.domains.create_value")
        }

        do_route /^do\s+domains?\s+delete\s+[^\s]+$/i, :delete, {
          t("help.domains.delete_key") => t("help.domains.delete_value")
        }

        do_route /^do\s+domains?\s+list$/i, :list, {
          t("help.domains.list_key") => t("help.domains.list_value")
        }

        do_route /^do\s+domains?\s+show\s+[^\s]+$/i, :show, {
          t("help.domains.show_key") => t("help.domains.show_value")
        }
      end

      Lita.register_handler(Domain)
    end
  end
end
