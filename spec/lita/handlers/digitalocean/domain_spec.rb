require "spec_helper"

describe Lita::Handlers::Digitalocean::Domain, lita_handler: true do
  it { routes_command("do domains create example.com 10.10.10.10").to(:domains_create) }
  it { routes_command("do domains delete example.com").to(:domains_delete) }
  it { routes_command("do domains list").to(:domains_list) }
  it { routes_command("do domains show example.com").to(:domains_show) }

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
