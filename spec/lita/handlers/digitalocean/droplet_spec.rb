require "spec_helper"

describe Lita::Handlers::Digitalocean::Droplet, lita_handler: true do
  it do
    routes_command(
      "do droplets create example.com 512mb centos-5-8-x64 nyc1"
    ).to(:create)
  end
  it { routes_command("do droplets delete 123").to(:delete) }
  it { routes_command("do droplets delete 123 scrub=true").to(:delete) }
  it { routes_command("do droplets list").to(:list) }
  it { routes_command("do droplets password reset 123").to(:password_reset) }
  it { routes_command("do droplets power cycle 123").to(:power_cycle) }
  it { routes_command("do droplets power off 123").to(:power_off) }
  it { routes_command("do droplets power on 123").to(:power_on) }
  it { routes_command("do droplets reboot 123").to(:reboot) }
  it { routes_command("do droplets rebuild 123 456").to(:rebuild) }
  it { routes_command("do droplets resize 123 1gb").to(:resize) }
  it { routes_command("do droplets restore 123 456").to(:restore) }
  it { routes_command("do droplets show 123").to(:show) }
  it { routes_command("do droplets shutdown 123").to(:shutdown) }
  it { routes_command("do droplets snapshot 123 'My Snapshot'").to(:snapshot) }

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

  describe "#create" do
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

  describe "#delete" do
    it "deletes a droplet" do
      allow(client_droplets).to receive(:delete).with("123", {}).and_return(
        status: "OK", droplet: { id: 123 }
      )
      send_command("do droplets delete 123")
      expect(replies.last).to eq("Deleted droplet: 123")
    end

    it "scrubs the disk before deleting the droplet" do
      allow(client_droplets).to receive(:delete).with("123", { scrub_data: true }).and_return(
        status: "OK", droplet: { id: 123 }
      )
      send_command("do droplets delete 123 scrub=true")
    end
  end

  describe "#list" do
    let(:do_droplets) do
      {
        status: "OK",
        droplets: [{
          id: 123,
          name: "image1",
          ip_address: "1.2.3.4"
        }, {
          id: 456,
          name: "image2",
          ip_address: "5.6.7.8"
        }]
      }
    end

    it "lists all droplets" do
      allow(client_droplets).to receive(:list).and_return(do_droplets)
      send_command("do droplets list")
      expect(replies).to eq([
        "ID: 123, Name: image1, IP: 1.2.3.4",
        "ID: 456, Name: image2, IP: 5.6.7.8"
      ])
    end
  end

  describe "#password_reset" do
    it "resets the root password" do
      allow(client_droplets).to receive(:password_reset).with("123").and_return(
        status: "OK", droplet: { id: 123 }
      )
      send_command("do droplets password reset 123")
      expect(replies.last).to eq("Password reset for droplet: 123")
    end
  end

  describe "#power_cycle" do
    it "cycles the droplet's power" do
      allow(client_droplets).to receive(:power_cycle).with("123").and_return(
        status: "OK", droplet: { id: 123 }
      )
      send_command("do droplets power cycle 123")
      expect(replies.last).to eq("Power cycled for droplet: 123")
    end
  end

  describe "#power_off" do
    it "powers off the droplet" do
      allow(client_droplets).to receive(:power_off).with("123").and_return(
        status: "OK", droplet: { id: 123 }
      )
      send_command("do droplets power off 123")
      expect(replies.last).to eq("Powered off droplet: 123")
    end
  end
end
