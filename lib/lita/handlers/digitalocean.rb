require "digital_ocean"
require "rash"

require_relative "digitalocean/domain"
require_relative "digitalocean/domain_record"
require_relative "digitalocean/droplet"
require_relative "digitalocean/image"
require_relative "digitalocean/region"
require_relative "digitalocean/ssh_key"
require_relative "digitalocean/size"

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

      include Domain
      include DomainRecord
      include Droplet
      include Image
      include Region
      include SSHKey
      include Size

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

        if do_response[:status] != "OK"
          response.reply(t("error", message: do_response[:message]))
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
              stripped_value = value.gsub(/\A["']|["']\Z/, "")
              hash[normalized_key] = case stripped_value
              when "true"
                true
              when "false"
                false
              else
                stripped_value
              end
            end
          end

          hash
        end
      end

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

    Lita.register_handler(Digitalocean)
  end
end
