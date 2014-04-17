module Lita
  module Handlers
    class Digitalocean < Handler
      class Region < Base
        do_route /^do\s+regions?\s+list$/i, :regions_list, {
          t("help.regions.list_key") => t("help.regions.list_value")
        }

        def regions_list(response)
          do_response = do_call(response) do |client|
            client.regions.list
          end or return

          messages = do_response[:regions].map { |region|  t("regions.details", region) }

          response.reply(*messages)
        end
      end

      Lita.register_handler(Region)
    end
  end
end
