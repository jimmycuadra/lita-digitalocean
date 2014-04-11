require "spec_helper"

describe Lita::Handlers::Digitalocean::SSHKeys do
  subject { described_class.new(handler, client) }
  let(:handler) { instance_double("Lita::Handlers::Digitalocean") }
  let(:client) { instance_double("::DigitalOcean::API") }
  let(:response) { instance_double("Lita::Response") }

  before { allow(handler).to receive(:do_call).and_yield }

  describe "#list" do
    before do
      allow(client).to receive_message_chain(:ssh_keys, :list).and_return(do_response)
    end

    context "with keys" do
      let(:do_response) do
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
        expect(response).to receive(:reply).with("1234 (My Key)")
        expect(response).to receive(:reply).with("5678 (Your Key)")
        subject.list(response)
      end
    end

    context "with no keys" do
      let(:do_response) { Hashie::Rash.new({ status: "OK", ssh_keys: [] }) }

      before { allow(handler).to receive(:t).with("ssh_keys.list.empty").and_return("OK") }

      it "replies with a message that there were no keys" do
        expect(response).to receive(:reply).with("OK")
        subject.list(response)
      end
    end
  end

  describe "#show" do
    let(:do_response) do
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
      allow(client).to receive_message_chain(:ssh_keys, :show).and_return(do_response)
    end

    it "shows the details of the key" do
      allow(response).to receive(:args).and_return(%w(ssh_keys show 123))
      expect(response).to receive(:reply).with("123 (My Key): ssh-rsa asdfjkl;")
      subject.show(response)
    end

    it "replies with an error message if a key wasn't provided" do
      allow(response).to receive(:args).and_return(%w(ssh_keys show))
      allow(handler).to receive(:t).with("ssh_keys.show.id_required").and_return("MISSING ARG")
      expect(response).to receive(:reply).with("MISSING ARG")
      subject.show(response)
    end
  end
end
