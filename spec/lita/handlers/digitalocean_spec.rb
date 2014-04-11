require "spec_helper"

describe Lita::Handlers::Digitalocean, lita_handler: true do
  it { routes_command("do ssh keys add 'foo bar' 'ssh-rsa abcdefg'").to(:ssh_keys_add) }
  it do
    routes_command(
      "do ssh keys edit 123 name=foo public_key='ssh-rsa changed'"
    ).to(:ssh_keys_edit)
  end
  it { routes_command("do ssh keys list").to(:ssh_keys_list) }
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

  describe "ssh key commands" do
    let(:do_list) do
      instance_double(
        "Hashie::Rash",
        status: "OK",
        ssh_keys: [
          instance_double("Hashie::Rash", id: 123, name: "My Key"),
          instance_double("Hashie::Rash", id: 456, name: "Your Key"),
        ]
      )
    end

    let(:do_list_empty) do
      instance_double(
        "Hashie::Rash",
        status: "OK",
        ssh_keys: []
      )
    end

    let(:do_key) do
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

    describe "#ssh_keys_add" do
      it "responds with the details of the new key" do
        allow(client).to receive_message_chain(:ssh_keys, :add).and_return(do_key)
        send_command("do ssh keys add 'My Key' 'ssh-rsa abcdefg'")
        expect(replies.last).to eq("Created new SSH key: 123 (My Key): ssh-rsa abcdefg")
      end

      it "responds with an error message if name or public key is missing" do
        send_command("do ssh keys add foo")
        expect(replies.last).to eq("Format: do ssh keys add NAME PUBLIC_KEY")
      end
    end

    describe "#ssh_keys_edit" do
      it "responds with the edited key's values" do
        allow(client).to receive_message_chain(:ssh_keys, :edit).and_return(do_key)
        send_command("do ssh keys edit 123 name='My Key' public_key='ssh-rsa abcdefg'")
        expect(replies.last).to eq("Updated SSH key: 123 (My Key): ssh-rsa abcdefg")
      end
    end

    describe "#ssh_keys_list" do
      it "returns a list of key IDs and names" do
        allow(client).to receive_message_chain(:ssh_keys, :list).and_return(do_list)
        send_command("do ssh keys list")
        expect(replies).to eq(["123 (My Key)", "456 (Your Key)"])
      end

      it "returns an empty state message if there are no SSH keys" do
        allow(client).to receive_message_chain(:ssh_keys, :list).and_return(do_list_empty)
        send_command("do ssh keys list")
        expect(replies.last).to eq("No SSH keys have been added yet.")
      end
    end

    describe "#ssh_keys_show" do
      it "responds with the public key" do
        allow(client).to receive_message_chain(:ssh_keys, :show).and_return(do_key)
        send_command("do ssh keys show 123")
        expect(replies.last).to eq("123 (My Key): ssh-rsa abcdefg")
      end
    end
  end
end
