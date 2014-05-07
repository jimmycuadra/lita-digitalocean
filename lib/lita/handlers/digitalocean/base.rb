require "digital_ocean"
require "hashie"

module Lita
  module Handlers
    class Digitalocean < Handler
      class Base < Handler
        # Override key for locale namespace.
        def self.name
          "Digitalocean"
        end

        private

        def self.do_route(regexp, route_name, help)
          route(regexp, route_name, command: true, restrict_to: :digitalocean_admins, help: help)
        end

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

      end
    end
  end
end
