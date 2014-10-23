require "spec_helper"

describe Lita::Handlers::Digitalocean::DomainRecord, lita_handler: true do
  it do
    is_expected.to route_command(
      "do domain records create example.com txt 'some value' --name example.com"
    ).to(:create)
  end
  it { is_expected.to route_command("do domain records delete example.com 123").to(:delete) }
  it do
    is_expected.to route_command(
      "do domain records edit example.com 123 txt 'some value' name=example.com"
    ).to(:edit)
  end
  it { is_expected.to route_command("do domain records list example.com").to(:list) }
  it { is_expected.to route_command("do domain records show example.com 123").to(:show) }

  let(:client) { instance_double("::DigitalOcean::API", domains: client_domains) }
  let(:client_domains) { instance_double("::DigitalOcean::Resource::Domain") }

  before do
    registry.config.handlers.digitalocean.tap do |config|
      config.client_id = "CLIENT_ID"
      config.api_key = "API_KEY"
    end

    robot.auth.add_user_to_group!(user, :digitalocean_admins)

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
      ).and_return(status: "OK", record: { id: 123 })
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

  describe "#list" do
    it "responds with a list of all domain records for the given record set" do
      allow(client_domains).to receive(:list_records).with("example.com").and_return(
        status: "OK",
        records: [{
          id: 123,
          record_type: "A",
          data: "10.0.0.0"
        }, {
          id: 456,
          record_type: "CNAME",
          data: "@"
        }]
      )
      send_command("do domain records list example.com")
      expect(replies).to eq([
        "ID: 123, Record Type: A, Data: 10.0.0.0",
        "ID: 456, Record Type: CNAME, Data: @"
      ])
    end
  end

  describe "#show" do
    it "responds with the details of the domain record" do
      allow(client_domains).to receive(:show_record).with("example.com", "123").and_return(
        status: "OK",
        record: {
          id: 123,
          record_type: "A",
          data: "10.0.0.0",
          name: "example.com",
          priority: 123,
          port: 456,
          weight: 789
        }
      )
      send_command("do domain records show example.com 123")
      expect(replies.last).to eq(
"ID: 123, Record Type: A, Data: 10.0.0.0, Name: example.com, Priority: 123, Port: 456, Weight: 789"
      )
    end
  end
end
