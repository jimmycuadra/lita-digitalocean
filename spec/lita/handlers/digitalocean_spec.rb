require "spec_helper"

describe Lita::Handlers::Digitalocean, lita_handler: true do
  it { routes_command("digitalocean anything").to(:dispatch) }
  it { routes_command("digital ocean anything").to(:dispatch) }
  it { routes_command("do anything").to(:dispatch) }

  let(:client) { instance_double("DigitalOcean::API") }

  before do
    Lita.config.handlers.digitalocean.client_id = 'CLIENT_ID'
    Lita.config.handlers.digitalocean.api_key = 'API_KEY'
    allow(::DigitalOcean::API).to receive(:new).and_return(client)
  end

  describe "#dispatch" do
    let(:submodule) { double("submodule", show: "responds to show") }
    let(:submodule_class) { double("Submodule", new: submodule) }

    before do
      stub_const("Lita::Handlers::Digitalocean::SUBMODULES", { ssh_keys: submodule_class })
    end

    it "dispatches messages to the appropriate submodule" do
      expect(submodule).to receive(:show).with(an_instance_of(Lita::Response))
      send_command("do ssh_keys show 123")
    end
  end
end
