module Lita
  module Handlers
    class Digitalocean < Handler
      class Size < Base
        do_route /^do\s+sizes\s+list$/, :list, {
          t("help.sizes.list_key") => t("help.sizes.list_value")
        }

        def list(response)
          do_response = do_call(response) do |client|
            client.sizes.list
          end or return

          messages = do_response[:sizes].map { |size| t("sizes.details", size) }

          response.reply(*messages)
        end
      end

      Lita.register_handler(Size)
    end
  end
end
