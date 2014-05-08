require "spec_helper"

describe Lita::Handlers::Digitalocean::DomainRecord, lita_handler: true do
  it do
    routes_command(
      "do domain records create example.com txt 'some value' --name example.com"
    ).to(:create)
  end
  it { routes_command("do domain records delete example.com 123").to(:delete) }
  it do
    routes_command(
      "do domain records edit example.com 123 txt 'some value' name=example.com"
    ).to(:edit)
  end
  it { routes_command("do domain records list example.com").to(:list) }
  it { routes_command("do domain records show example.com 123").to(:show) }

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
    it "creates a new domain record" do
      allow(client_domains).to receive(:create_record).with(
        "example.com",
        data: "@",
        name: "foo",
        port: "456",
        priority: "123",
        record_type: "srv",
        weight: "789"
      ).and_return(status: "OK", domain_record: { id: 123 })
      send_command("do domain records create example.com srv @ --name foo --priority 123 --port 456 --weight 789")
      expect(replies.last).to eq("Created new DNS record: 123")
    end
  end

  describe "#delete" do
    it "deletes a domain record" do
      allow(client_domains).to receive(:delete_record).with("123", "456").and_return(status: "OK")
      send_command("do domain records delete 123 456")
      expect(replies.last).to eq("Deleted DNS record.")
    end
  end

  describe "#edit" do
    it "edits a domain record" do
      allow(client_domains).to receive(:edit_record).with(
        "example.com",
        "123",
        data: "example.com",
        record_type: "cname",
        name: "www.example.com"
      ).and_return(status: "OK")
      send_command(
        "do domain records edit example.com 123 cname example.com --name www.example.com"
      )
      expect(replies.last).to eq("Updated DNS record.")
    end
  end
end
