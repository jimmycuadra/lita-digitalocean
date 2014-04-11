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

    it "returns the DO error message if there was an error" do
      allow(submodule).to receive(:list).and_raise(
        Lita::Handlers::Digitalocean::APIError,
        "lol"
      )
      send_command("do ssh_keys list")
      expect(replies.last).to eq("DigitalOcean API error: lol")
    end
  end

  describe "#do_call" do
    let(:successful_do_response) { Hashie::Rash.new(status: "OK") }
    let(:unsuccessful_do_response) { Hashie::Rash.new(status: "ERROR", message: "lol") }

    it "returns the DO response on success" do
      do_response = subject.do_call { successful_do_response }
      expect(do_response).to eq(successful_do_response)
    end

    it "raises APIError on error" do
      expect do
        subject.do_call { unsuccessful_do_response }
      end.to raise_error(Lita::Handlers::Digitalocean::APIError, "lol")
    end
  end
end
