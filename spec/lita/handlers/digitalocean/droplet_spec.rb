require "spec_helper"

describe Lita::Handlers::Digitalocean::Droplet, lita_handler: true do
  it do
    is_expected.to route_command(
      "do droplets create example.com 512mb centos-5-8-x64 nyc1"
    ).to(:create)
  end
  it { is_expected.to route_command("do droplets delete 123").to(:delete) }
  it { is_expected.to route_command("do droplets delete 123 --scrub").to(:delete) }
  it { is_expected.to route_command("do droplets list").to(:list) }
  it { is_expected.to route_command("do droplets password reset 123").to(:password_reset) }
  it { is_expected.to route_command("do droplets power cycle 123").to(:power_cycle) }
  it { is_expected.to route_command("do droplets power off 123").to(:power_off) }
  it { is_expected.to route_command("do droplets power on 123").to(:power_on) }
  it { is_expected.to route_command("do droplets reboot 123").to(:reboot) }
  it { is_expected.to route_command("do droplets rebuild 123 456").to(:rebuild) }
  it { is_expected.to route_command("do droplets resize 123 1gb").to(:resize) }
  it { is_expected.to route_command("do droplets restore 123 456").to(:restore) }
  it { is_expected.to route_command("do droplets show 123").to(:show) }
  it { is_expected.to route_command("do droplets shutdown 123").to(:shutdown) }
  it { is_expected.to route_command("do droplets snapshot 123 'My Snapshot'").to(:snapshot) }

  let(:client) { instance_double("::DigitalOcean::API", droplets: client_droplets) }
  let(:client_droplets) { instance_double("::DigitalOcean::Resource::Droplet") }

  let(:do_ok) { { status: "OK" } }

  before do
    registry.config.handlers.digitalocean.tap do |config|
      config.client_id = "CLIENT_ID"
      config.api_key = "API_KEY"
    end

    robot.auth.add_user_to_group!(user, :digitalocean_admins)

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
do droplets create example.com 1 2 3 --ssh-key-ids 1,2,3 --private-networking --backups_enabled
COMMAND
    end
  end

  describe "#delete" do
    it "deletes a droplet" do
      allow(client_droplets).to receive(:delete).with("123", {}).and_return(do_ok)
      send_command("do droplets delete 123")
      expect(replies.last).to eq("Deleted droplet: 123")
    end

    it "scrubs the disk before deleting the droplet" do
      allow(client_droplets).to receive(:delete).with(
        "123", {
          scrub_data: true
        }).and_return(do_ok)
      send_command("do droplets delete 123 --scrub")
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
      allow(client_droplets).to receive(:password_reset).with("123").and_return(do_ok)
      send_command("do droplets password reset 123")
      expect(replies.last).to eq("Password reset for droplet: 123")
    end
  end

  describe "#power_cycle" do
    it "cycles the droplet's power" do
      allow(client_droplets).to receive(:power_cycle).with("123").and_return(do_ok)
      send_command("do droplets power cycle 123")
      expect(replies.last).to eq("Power cycled for droplet: 123")
    end
  end

  describe "#power_off" do
    it "powers off the droplet" do
      allow(client_droplets).to receive(:power_off).with("123").and_return(do_ok)
      send_command("do droplets power off 123")
      expect(replies.last).to eq("Powered off droplet: 123")
    end
  end

  describe "#power_on" do
    it "powers on the droplet" do
      allow(client_droplets).to receive(:power_on).with("123").and_return(do_ok)
      send_command("do droplets power on 123")
      expect(replies.last).to eq("Powered on droplet: 123")
    end
  end

  describe "#reboot" do
    it "reboots the droplet" do
      allow(client_droplets).to receive(:reboot).with("123").and_return(do_ok)
      send_command("do droplets reboot 123")
      expect(replies.last).to eq("Rebooted droplet: 123")
    end
  end

  describe "#rebuild" do
    it "rebuilds the droplet with the provided image" do
      allow(client_droplets).to receive(:rebuild).with("123", image_id: "456").and_return(do_ok)
      send_command("do droplets rebuild 123 456")
      expect(replies.last).to eq("Rebuilt droplet: 123")
    end
  end

  describe "#resize" do
    it "resizes the droplet with the provided size ID" do
      allow(client_droplets).to receive(:resize).with("123", size_id: "456").and_return(do_ok)
      send_command("do droplets resize 123 456")
      expect(replies.last).to eq("Resized droplet: 123")
    end

    it "resizes the droplet with the provided size slug" do
      allow(client_droplets).to receive(:resize).with("123", size_slug: "1gb").and_return(do_ok)
      send_command("do droplets resize 123 1gb")
      expect(replies.last).to eq("Resized droplet: 123")
    end
  end

  describe "#restore" do
    it "restores the droplet to the provided image" do
      allow(client_droplets).to receive(:restore).with("123", image_id: "456").and_return(do_ok)
      send_command("do droplets restore 123 456")
      expect(replies.last).to eq("Restored droplet: 123")
    end
  end

  describe "#show" do
    it "responds with the details of the droplet" do
      allow(client_droplets).to receive(:show).with("123").and_return(
        status: "OK",
        droplet: {
          id: 123,
          image_id: 456,
          name: "My Droplet",
          region_id: 1,
          size_id: 33,
          backups_active: true,
          backups: [],
          snapshots: [],
          ip_address: "1.2.3.4",
          private_ip_address: "5.6.7.8",
          locked: false,
          status: "active"
        }
      )
      send_command("do droplets show 123")
      expect(replies.last).to eq <<-DROPLET.chomp
ID: 123, Image ID: 456, Name: My Droplet, Region ID: 1, Size ID: 33, Backups active: true, \
Backups: [], Snapshots: [], IP address: 1.2.3.4, Private IP address: 5.6.7.8, Locked: false, \
Status: active
DROPLET
    end
  end

  describe "#shutdown" do
    it "shuts down the droplet" do
      allow(client_droplets).to receive(:shutdown).with("123").and_return(do_ok)
      send_command("do droplets shutdown 123")
      expect(replies.last).to eq("Shut down droplet: 123")
    end
  end

  describe "#snapshot" do
    it "takes a snapshot of the droplet" do
      allow(client_droplets).to receive(:snapshot).with("123", {}).and_return(do_ok)
      send_command("do droplets snapshot 123")
      expect(replies.last).to eq("Snapshotted droplet: 123")
    end

    it "takes a named snapshot of the droplet" do
      allow(client_droplets).to receive(:snapshot).with("123", name: "My Droplet").and_return(do_ok)
      send_command("do droplets snapshot 123 'My Droplet'")
      expect(replies.last).to eq("Snapshotted droplet: 123")
    end
  end
end
