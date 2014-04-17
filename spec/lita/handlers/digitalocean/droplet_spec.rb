require "spec_helper"

describe Lita::Handlers::Digitalocean::Droplet, lita_handler: true do
  it do
    routes_command(
      "do droplets create example.com 512mb centos-5-8-x64 nyc1"
    ).to(:droplets_create)
  end
  it { routes_command("do droplets delete 123 scrub").to(:droplets_delete) }
  it { routes_command("do droplets list").to(:droplets_list) }
  it { routes_command("do droplets password reset 123").to(:droplets_password_reset) }
  it { routes_command("do droplets power cycle 123").to(:droplets_power_cycle) }
  it { routes_command("do droplets power off 123").to(:droplets_power_off) }
  it { routes_command("do droplets power on 123").to(:droplets_power_on) }
  it { routes_command("do droplets reboot 123").to(:droplets_reboot) }
  it { routes_command("do droplets rebuild 123 456").to(:droplets_rebuild) }
  it { routes_command("do droplets resize 123 1gb").to(:droplets_resize) }
  it { routes_command("do droplets restore 123 456").to(:droplets_restore) }
  it { routes_command("do droplets show 123").to(:droplets_show) }
  it { routes_command("do droplets shutdown 123").to(:droplets_shutdown) }
  it { routes_command("do droplets snapshot 123 'My Snapshot'").to(:droplets_snapshot) }

  # Common setup

  let(:client) { instance_double("::DigitalOcean::API", droplets: client_droplets) }
  let(:client_droplets) { instance_double("::DigitalOcean::Resource::Droplet") }

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

  describe "droplets commands" do
    describe "#droplets_create" do
      it "creates a new droplet using slugs" do
        allow(client_droplets).to receive(:create).with(
          name: "example.com",
          size_slug: "512mb",
          image_slug: "centos-5-8-x64",
          region_slug: "nyc1"
        ).and_return(status: "OK", droplet: { id: 123, name: "example.com" })
        send_command("do droplets create example.com 512mb centos-5-8-x64 nyc1")
        expect(replies.last).to eq("Created new droplet: 123 (example.com)")
      end

      it "creates a new droplet using IDs" do
        allow(client_droplets).to receive(:create).with(
          name: "example.com",
          size_id: "1",
          image_id: "2",
          region_id: "3"
        ).and_return(status: "OK", droplet: { id: 123, name: "example.com" })
        send_command("do droplets create example.com 1 2 3")
        expect(replies.last).to eq("Created new droplet: 123 (example.com)")
      end

      it "creates a new droplet with optional parameters" do
        expect(client_droplets).to receive(:create).with(
          hash_including(ssh_key_ids: "1,2,3", private_networking: true, backups_enabled: true)
        ).and_return(status: "OK", droplet: { id: 123, name: "example.com" })
        send_command <<-COMMAND.chomp
do droplets create example.com 1 2 3 ssh_key_ids=1,2,3 private_networking=true \
backups_enabled=true
COMMAND
      end
    end
  end
end
