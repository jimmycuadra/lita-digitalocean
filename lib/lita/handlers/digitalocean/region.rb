module Lita
  module Handlers
    class Digitalocean < Handler
      module Region
        def self.included(base)
          base.instance_eval do
            do_route /^do\s+regions?\s+list$/i, :regions_list, {
              t("help.regions.list_key") => t("help.regions.list_value")
            }
          end

          def regions_list(response)
            do_response = do_call(response) do |client|
              client.regions.list
            end or return

            messages = do_response[:regions].map { |region|  t("regions.details", region) }

            response.reply(*messages)
          end
        end
      end
    end
  end
end
