require "spec_helper"

describe Lita::Handlers::Digitalocean::Domain, lita_handler: true do
  it { routes_command("do domains create example.com 10.10.10.10").to(:create) }
  it { routes_command("do domains delete example.com").to(:delete) }
  it { routes_command("do domains list").to(:list) }
  it { routes_command("do domains show example.com").to(:show) }

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

  describe "#create" do
    it "creates a new DNS record set" do
      allow(client_domains).to receive(:create).with(
        name: "example.com",
        ip_address: "10.0.0.0"
      ).and_return(status: "OK", domain: { id: 123, name: "example.com" })
      send_command("do domains create example.com 10.0.0.0")
      expect(replies.last).to eq("Created new DNS record set for example.com.")
    end
  end

  describe "#delete" do
    it "deletes a DNS record set" do
      allow(client_domains).to receive(:delete).with("123").and_return(status: "OK")
      send_command("do domains delete 123")
      expect(replies.last).to eq("Deleted DNS record set.")
    end
  end

  describe "#list" do
    it "lists all DNS record sets" do
      allow(client_domains).to receive(:list).and_return(
        status: "OK",
        domains: [{
          id: 123,
          name: "example.com"
        }, {
          id: 456,
          name: "another.example.com"
        }]
      )
      send_command("do domains list")
      expect(replies).to eq([
        "ID: 123, Name: example.com",
        "ID: 456, Name: another.example.com"
      ])
    end
  end
end
