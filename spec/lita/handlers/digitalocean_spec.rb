require "spec_helper"

describe Lita::Handlers::Digitalocean, lita_handler: true do
  it { routes_command("do ssh_keys list").to(:ssh_keys_list) }
  it { routes_command("do ssh_keys show 123").to(:ssh_keys_show) }

  let(:client) { instance_double("DigitalOcean::API") }

  before do
    Lita.config.handlers.digitalocean.client_id = 'CLIENT_ID'
    Lita.config.handlers.digitalocean.api_key = 'API_KEY'
    allow(::DigitalOcean::API).to receive(:new).and_return(client)
  end

  describe "#ssh_keys_list" do
    before do
      allow(client).to receive_message_chain(:ssh_keys, :list).and_return(response)
    end

    context "with keys" do
      let(:response) do
        Hashie::Rash.new({
          status: "OK",
          ssh_keys: [{
            id: 1234, name: "My Key"
          }, {
            id: 5678, name: "Your Key"
          }]
        })
      end

      it "replies with a list of key IDs and names" do
        send_command("do ssh_keys list")
        expect(replies).to eq ["1234: My Key", "5678: Your Key"]
      end
    end

    context "with no keys" do
      let(:response) { Hashie::Rash.new({ status: "OK", ssh_keys: [] }) }

      it "replies with a message that there were no keys" do
        send_command("do ssh_keys list")
        expect(replies.last).to eq("No SSH keys have been added yet.")
      end
    end

    context "with an error response" do
      let(:response) { Hashie::Rash.new({ status: "ERROR" }) }

      it "replies with an error message" do
        send_command("do ssh_keys list")
        expect(replies.last).to eq("There was an error communicating with DigitalOcean.")
      end
    end
  end

  describe "#ssh_keys_show" do
    let(:response) do
      Hashie::Rash.new({
        status: "OK",
        ssh_key: {
          id: 123,
          name: "My Key",
          ssh_pub_key: "ssh-rsa asdfjkl;"
        }
      })
    end

    before do
      allow(client).to receive_message_chain(:ssh_keys, :show).and_return(response)
    end

    it "shows the details of the key" do
      send_command("do ssh_keys show 123")
      expect(replies.last).to eq("123 (My Key): ssh-rsa asdfjkl;")
    end
  end
end
