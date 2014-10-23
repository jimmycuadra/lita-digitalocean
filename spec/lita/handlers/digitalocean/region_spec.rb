require "spec_helper"

describe Lita::Handlers::Digitalocean::Region, lita_handler: true do
  it { is_expected.to route_command("do regions list").to(:list) }

  let(:client) { instance_double("::DigitalOcean::API", regions: client_regions) }
  let(:client_regions) { instance_double("::DigitalOcean::Resource::Region") }

  before do
    registry.config.handlers.digitalocean.tap do |config|
      config.client_id = "CLIENT_ID"
      config.api_key = "API_KEY"
    end

    robot.auth.add_user_to_group!(user, :digitalocean_admins)

    allow(::DigitalOcean::API).to receive(:new).and_return(client)
  end

  let(:do_list) do
    {
      status: "OK",
      regions: [
        { id: 1, name: "New York 1", slug: "nyc1" },
        { id: 2, name: "Amsterdam 1", slug: "ams1" }
      ]
    }
  end

  describe "#list" do
    it "responds with a list of all regions" do
      allow(client_regions).to receive(:list).and_return(do_list)
      send_command("do regions list")
      expect(replies).to eq ([
        "ID: 1, Name: New York 1, Slug: nyc1",
        "ID: 2, Name: Amsterdam 1, Slug: ams1"
      ])
    end
  end
end
