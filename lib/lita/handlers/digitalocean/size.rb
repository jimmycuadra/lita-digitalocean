module Lita
  module Handlers
    class Digitalocean < Handler
      module Size
        def self.included(base)
          base.instance_eval do
            do_route /^do\s+sizes\s+list$/, :sizes_list, {
              t("help.sizes.list_key") => t("help.sizes.list_value")
            }
          end
        end

        def sizes_list(response)
          do_response = do_call(response) do |client|
            client.sizes.list
          end or return

          messages = do_response[:sizes].map { |size| t("sizes.details", size) }

          response.reply(*messages)
        end
      end
    end
  end
end
