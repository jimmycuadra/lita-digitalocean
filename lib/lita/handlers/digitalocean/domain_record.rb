module Lita
  module Handlers
    class Digitalocean < Handler
      module DomainRecord
        def self.included(base)
          base.instance_eval do
            do_route(
              /^do\s+domain\s+records?\s+create\s(?:[^\s]+\s+){2}[^\s]/i,
              :domain_records_create,
              {
                t("help.domain_records.create_key") => t("help.domain_records.create_value")
              }
            )

            do_route(
              /^do\s+domain\s+records?\s+delete\s+[^\s]+\s+\d+$/i,
              :domain_records_delete,
              {
                t("help.domain_records.delete_key") => t("help.domain_records.delete_value")
              }
            )

            do_route(
              /^do\s+domain\s+records?\s+edit\s+(?:[^\s]+\s+){3}[^\s]+/i,
              :domain_records_edit,
              {
                t("help.domain_records.edit_key") => t("help.domain_records.edit_value")
              }
            )

            do_route(
              /^do\s+domain\s+records?\s+list\s+[^\s]+$/i,
              :domain_records_list,
              {
                t("help.domain_records.list_key") => t("help.domain_records.list_value")
              }
            )

            do_route(
              /^do\s+domain\s+records?\s+show\s+[^\s]+\s+\d+$/i,
              :domain_records_show,
              {
                t("help.domain_records.show_key") => t("help.domain_records.show_value")
              }
            )
          end
        end
      end
    end
  end
end
