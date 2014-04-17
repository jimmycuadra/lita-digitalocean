require "spec_helper"

describe Lita::Handlers::Digitalocean::DomainRecord, lita_handler: true do
  it do
    routes_command(
      "do domain records create example.com txt 'some value' name=example.com"
    ).to(:domain_records_create)
  end
  it { routes_command("do domain records delete example.com 123").to(:domain_records_delete) }
  it do
    routes_command(
      "do domain records edit example.com 123 txt 'some value' name=example.com"
    ).to(:domain_records_edit)
  end
  it { routes_command("do domain records list example.com").to(:domain_records_list) }
  it { routes_command("do domain records show example.com 123").to(:domain_records_show) }

  let(:client) { instance_double("::DigitalOcean::API", domains: client_domains) }
  let(:client_domains) { instance_double("::DigitalOcean::Resource::Domain") }

  before do
    Lita.config.handlers.digitalocean = Lita::Config.new
    Lita.config.handlers.digitalocean.tap do |config|
      config.client_id = "CLIENT_ID"
      config.api_key = "API_KEY"
    end

    allow(Lita::Authorization).to receive(:user_in_group?).with(
      user,
      :digitalocean_admins
    ).and_return(true)

    allow(::DigitalOcean::API).to receive(:new).and_return(client)
  end
end
