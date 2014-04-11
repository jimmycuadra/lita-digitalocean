require "spec_helper"

describe Lita::Handlers::Digitalocean, lita_handler: true do
  it { routes_command("do ssh keys list").to(:ssh_keys_list) }
  it { routes_command("do ssh key list").to(:ssh_keys_list) }
  it { routes_command("do ssh keys show 123").to(:ssh_keys_show) }

  let(:client) { instance_double("::DigitalOcean::API") }

  before do
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

  describe "#ssh_keys_list" do
    let(:do_response_success) do
      instance_double(
        "Hashie::Rash",
        status: "OK",
        ssh_keys: [
          instance_double("Hashie::Rash", id: 123, name: "My Key"),
          instance_double("Hashie::Rash", id: 456, name: "Your Key"),
        ]
      )
    end

    let(:do_response_empty) do
      instance_double(
        "Hashie::Rash",
        status: "OK",
        ssh_keys: []
      )
    end

    it "returns a list of key IDs and names" do
      allow(client).to receive_message_chain(:ssh_keys, :list).and_return(do_response_success)
      send_command("do ssh keys list")
      expect(replies).to eq(["123 (My Key)", "456 (Your Key)"])
    end

    it "returns an empty state message if there are no SSH keys" do
      allow(client).to receive_message_chain(:ssh_keys, :list).and_return(do_response_empty)
      send_command("do ssh keys list")
      expect(replies.last).to eq("No SSH keys have been added yet.")
    end
  end

  describe "#ssh_keys_show" do
    let(:do_response) do
      instance_double(
        "Hashie::Rash",
        status: "OK",
        ssh_key: instance_double(
          "Hashie::Rash",
          id: 123,
          name: "My Key",
          ssh_pub_key: "ssh-rsa abcdefg"
        )
      )
    end

    it "responds with the public key" do
      allow(client).to receive_message_chain(:ssh_keys, :show).and_return(do_response)
      send_command("do ssh keys show 123")
      expect(replies.last).to eq("123 (My Key): ssh-rsa abcdefg")
    end
  end
end
