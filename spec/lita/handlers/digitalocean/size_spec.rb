require "spec_helper"

describe Lita::Handlers::Digitalocean::Size, lita_handler: true do
  it { routes_command("do sizes list").to(:sizes_list) }

  let(:client) { instance_double( "::DigitalOcean::API", sizes: client_sizes) }
  let(:client_sizes) { instance_double("::DigitalOcean::Resource::Size") }

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

  describe "sizes commands" do
    let(:do_sizes) do
      {
        status: "OK",
        sizes: [
          { id: 33, name: "512MB", slug: "512mb" },
          { id: 34, name: "1GB", slug: "1gb" }
        ]
      }
    end

    describe "#sizes_list" do
      it "responds with a list of all sizes" do
        allow(client_sizes).to receive(:list).and_return(do_sizes)
        send_command("do sizes list")
        expect(replies).to eq([
          'ID: 33, Name: 512MB, Slug: 512mb',
          'ID: 34, Name: 1GB, Slug: 1gb'
        ])
      end
    end
  end
end
