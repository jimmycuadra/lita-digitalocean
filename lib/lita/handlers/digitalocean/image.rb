module Lita
  module Handlers
    class Digitalocean < Handler
      class Image < Base
        do_route /^do\s+images?\s+delete\s+([^\s]+)$/i, :images_delete, {
          t("help.images.delete_key") => t("help.images.delete_value")
        }

        do_route /^do\s+images?\s+list\s*.*$/i, :images_list, {
          t("help.images.list_key") => t("help.images.list_value")
        }

        do_route /^do\s+images?\s+show\s([^\s]+)$/i, :images_show, {
          t("help.images.show_key") => t("help.images.show_value")
        }

        def images_delete(response)
          image_id = response.args[2]

          do_response = do_call(response) do |client|
            client.images.delete(image_id)
          end or return

          response.reply(t("images.delete.deleted", image_id: image_id))
        end

        def images_list(response)
          filter = response.args[2]
          normalized_filter = filter.to_s.downcase
          options = {}

          if filter && %(global my_images).include?(normalized_filter)
            options[:filter] = normalized_filter
          end

          do_response = do_call(response) do |client|
            client.images.list(options)
          end or return

          messages = do_response[:images].map { |image| t("images.details", formatted_image(image)) }

          response.reply(*messages)
        end

        def images_show(response)
          image_id = response.args[2]

          do_response = do_call(response) do |client|
            client.images.show(image_id)
          end or return

          response.reply(t("images.details", formatted_image(do_response[:image])))
        end

        private

        def format_array(array)
          %([#{array.join(",")}])
        end

        def formatted_image(image)
          Hashie::Rash.new image.merge(
            formatted_regions: format_array(image[:regions]),
            formatted_region_slugs: format_array(image[:region_slugs])
          )
        end
      end

      Lita.register_handler(Image)
    end
  end
end
