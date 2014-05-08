module Lita
  module Handlers
    class Digitalocean < Handler
      class DomainRecord < Base
        do_route /^do\s+domain\s+records?\s+create\s(?:[^\s]+\s+){2}[^\s]/i, :create, {
          t("help.domain_records.create_key") => t("help.domain_records.create_value")
        }, {
          name: {},
          priority: {},
          port: {},
          weight: {}
        }

        do_route /^do\s+domain\s+records?\s+delete\s+[^\s]+\s+\d+$/i, :delete, {
          t("help.domain_records.delete_key") => t("help.domain_records.delete_value")
        }

        do_route /^do\s+domain\s+records?\s+edit\s+(?:[^\s]+\s+){3}[^\s]+/i, :edit, {
          t("help.domain_records.edit_key") => t("help.domain_records.edit_value")
        }, {
          name: {},
          priority: {},
          port: {},
          weight: {}
        }

        do_route /^do\s+domain\s+records?\s+list\s+[^\s]+$/i, :list, {
          t("help.domain_records.list_key") => t("help.domain_records.list_value")
        }

        do_route /^do\s+domain\s+records?\s+show\s+[^\s]+\s+\d+$/i, :show, {
          t("help.domain_records.show_key") => t("help.domain_records.show_value")
        }

        def create(response)
          id, type, data = response.args[3..5]

          params = {
            data: data,
            record_type: type
          }.merge(response.extensions[:kwargs])

          do_response = do_call(response) do |client|
            client.domains.create_record(id, params)
          end or return

          response.reply(t("domain_records.create.created", do_response[:domain_record]))
        end

        def delete(response)
          id, record_id = response.args[3..4]

          do_response = do_call(response) do |client|
            client.domains.delete_record(id, record_id)
          end or return

          response.reply(t("domain_records.delete.deleted"))
        end

        def edit(response)
          id, record_id, type, data = response.args[3..6]

          params = {
            data: data,
            record_type: type
          }.merge(response.extensions[:kwargs].reject { |_key, value| value.nil? })

          do_response = do_call(response) do |client|
            client.domains.edit_record(id, record_id, params)
          end or return

          response.reply(t("domain_records.edit.updated"))
        end

        def list(response)
          do_response = do_call(response) do |client|
            client.domains.list_records(response.args[3])
          end or return

          messages = do_response[:records].map { |record| t("domain_records.list.detail", record) }

          response.reply(*messages)
        end
      end

      Lita.register_handler(DomainRecord)
    end
  end
end
