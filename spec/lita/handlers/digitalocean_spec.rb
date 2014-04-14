require "spec_helper"

describe Lita::Handlers::Digitalocean, lita_handler: true do

  # Domain routes

  it { routes_command("do domains create example.com 10.10.10.10").to(:domains_create) }
  it { routes_command("do domains delete example.com").to(:domains_delete) }
  it { routes_command("do domains list").to(:domains_list) }
  it { routes_command("do domains show example.com").to(:domains_show) }

  # Domain record routes

  it do
    routes_command(
      "do domain records create example.com txt 'some value' name=example.com"
    ).to(:domain_records_create)
  end
  it { routes_command("do domain records delete example.com 123").to(:domain_records_delete) }
  it do
    routes_command(
      "do domain records edit example.com 123 txt 'some value' name=example.com"
    ).to(:domain_records_edit)
  end
  it { routes_command("do domain records list example.com").to(:domain_records_list) }
  it { routes_command("do domain records show example.com 123").to(:domain_records_show) }

  # Droplet routes

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

  # Image routes

  it { routes_command("do images delete 123").to(:images_delete) }
  it { routes_command("do images list").to(:images_list) }
  it { routes_command("do images list filter").to(:images_list) }
  it { routes_command("do images show 123").to(:images_show) }

  # Region routes

  it { routes_command("do regions list").to(:regions_list) }

  # SSH key routes

  it { routes_command("do ssh keys add 'foo bar' 'ssh-rsa abcdefg'").to(:ssh_keys_add) }
  it { routes_command("do ssh keys delete 123").to(:ssh_keys_delete) }
  it do
    routes_command(
      "do ssh keys edit 123 name=foo public_key='ssh-rsa changed'"
    ).to(:ssh_keys_edit)
  end
  it { routes_command("do ssh keys list").to(:ssh_keys_list) }
  it { routes_command("do ssh keys show 123").to(:ssh_keys_show) }

  # Size routes

  it { routes_command("do sizes list").to(:sizes_list) }

  # Common setup

  let(:client) do
    instance_double(
      "::DigitalOcean::API",
      droplets: client_droplets,
      images: client_images,
      regions: client_regions,
      ssh_keys: client_ssh_keys,
      sizes: client_sizes
    )
  end

  let(:client_droplets) { instance_double("::DigitalOcean::Resource::Droplet") }
  let(:client_images) { instance_double("::DigitalOcean::Resource::Image") }
  let(:client_regions) { instance_double("::DigitalOcean::Resource::Region") }
  let(:client_ssh_keys) { instance_double("::DigitalOcean::Resource::SSHKey") }
  let(:client_sizes) { instance_double("::DigitalOcean::Resource::Size") }

  let(:do_delete) { { status: "OK" } }

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

    describe "#droplets_delete" do
      let(:do_droplet) { { status: "OK", droplet: { id: 123 } } }

      it "deletes droplets" do
        allow(client_droplets).to receive(:delete).with("123", {}).and_return(do_droplet)
        send_command("do droplets delete 123")
        expect(replies.last).to eq("Deleted droplet: 123")
      end

      it "scrubs data before deleting the droplet" do
        allow(client_droplets).to receive(:delete).with(
          "123",
          scrub_data: true
        ).and_return(do_droplet)
        send_command("do droplets delete 123 scrub=true")
        expect(replies.last).to eq("Deleted droplet: 123")
      end
    end
  end

  describe "images commands" do
    let(:public_image) do
      {
        id: 1601,
        name: "CentOS 5.8 x64",
        slug: "centos-5-8-x64",
        distribution: "CentOS",
        public: true,
        regions: [1, 2, 3, 4, 5, 6],
        region_slugs: %w(nyc1 ams1 sfo1 nyc2 ams2 sgp1)
      }
    end

      let(:public_image_message) do
        <<-IMAGE.chomp
ID: 1601, Name: CentOS 5.8 x64, Slug: centos-5-8-x64, Distribution: CentOS, Public: true, \
Regions: [1,2,3,4,5,6], Region Slugs: [nyc1,ams1,sfo1,nyc2,ams2,sgp1]
IMAGE
      end

    describe "#images_delete" do
      it "responds with a success message" do
        allow(client_images).to receive(:delete).with("123").and_return(do_delete)
        send_command("do images delete 123")
        expect(replies.last).to eq("Deleted image: 123")
      end
    end

    describe "#images_list" do
      let(:private_image) do
        {
          "id" => 1602,
          name: "CentOS 5.8 x32",
          slug: "centos-5-8-x32",
          distribution: "CentOS",
          public: false,
          regions: [1, 2, 3],
          region_slugs: %w(nyc1 ams1 sfo1)
        }
      end

      let(:do_images) do
        {
          status: "OK",
          images: [public_image, private_image]
        }
      end

      let(:do_public_images) do
        {
          status: "OK",
          images: [public_image]
        }
      end

      let(:do_private_images) do
        {
          status: "OK",
          images: [private_image]
        }
      end

      let(:private_image_message) do
        <<-IMAGE.chomp
ID: 1602, Name: CentOS 5.8 x32, Slug: centos-5-8-x32, Distribution: CentOS, Public: false, \
Regions: [1,2,3], Region Slugs: [nyc1,ams1,sfo1]
IMAGE
      end

      it "responds with a list of all available images" do
        allow(client_images).to receive(:list).and_return(do_images)
        send_command("do images list")
        expect(replies).to eq([public_image_message, private_image_message])
      end

      it "responds with a list of only public images" do
        allow(client_images).to receive(:list).with(
          filter: "global"
        ).and_return(do_public_images)
        send_command("do images list global")
        expect(replies.last).to eq(public_image_message)
      end
    end

    describe "#images_show" do
      it "responds with the details of the image" do
        allow(client_images).to receive(:show).with("123").and_return(
          { status: "OK", image: public_image }
        )
        send_command("do images show 123")
        expect(replies.last).to eq(public_image_message)
      end
    end
  end

  describe "regions commands" do
    let(:do_list) do
      {
        status: "OK",
        regions: [
          { id: 1, name: "New York 1", slug: "nyc1" },
          { id: 2, name: "Amsterdam 1", slug: "ams1" }
        ]
      }
    end

    describe "#regions_list" do
      it "responds with a list of all regions" do
        allow(client_regions).to receive(:list).and_return(do_list)
        send_command("do regions list")
        expect(replies).to eq ([
          "ID: 1, Name: New York 1, Slug: nyc1",
          "ID: 2, Name: Amsterdam 1, Slug: ams1"
        ])
      end
    end
  end

  describe "ssh key commands" do
    let(:do_list) do
      {
        status: "OK",
        ssh_keys: [
          { id: 123, name: "My Key" },
          { id: 456, name: "Your Key" }
        ]
      }
    end

    let(:do_list_empty) do
      {
        status: "OK",
        ssh_keys: []
      }
    end

    let(:do_key) do
      {
        status: "OK",
        ssh_key: {
          id: 123,
          name: "My Key",
          ssh_pub_key: "ssh-rsa abcdefg"
        }
      }
    end

    describe "#ssh_keys_add" do
      it "responds with the details of the new key" do
        allow(client_ssh_keys).to receive(:add).with(
          name: "My Key",
          ssh_pub_key: "ssh-rsa abcdefg"
        ).and_return(do_key)
        send_command("do ssh keys add 'My Key' 'ssh-rsa abcdefg'")
        expect(replies.last).to eq("Created new SSH key: 123 (My Key): ssh-rsa abcdefg")
      end

      it "responds with an error message if name or public key is missing" do
        send_command("do ssh keys add foo")
        expect(replies.last).to eq("Format: do ssh keys add NAME PUBLIC_KEY")
      end
    end

    describe "#ssh_keys_delete" do
      it "responds with a success message" do
        allow(client_ssh_keys).to receive(:delete).with("123").and_return(do_delete)
        send_command("do ssh keys delete 123")
        expect(replies.last).to eq("Deleted SSH key: 123")
      end
    end

    describe "#ssh_keys_edit" do
      it "responds with the edited key's values" do
        allow(client_ssh_keys).to receive(:edit).with(
          "123",
          name: "My Key",
          ssh_pub_key: "ssh-rsa abcdefg"
        ).and_return(do_key)
        send_command(%{do ssh keys edit 123 name='My Key' public_key="ssh-rsa abcdefg"})
        expect(replies.last).to eq("Updated SSH key: 123 (My Key): ssh-rsa abcdefg")
      end
    end

    describe "#ssh_keys_list" do
      it "returns a list of key IDs and names" do
        allow(client_ssh_keys).to receive(:list).and_return(do_list)
        send_command("do ssh keys list")
        expect(replies).to eq(["123 (My Key)", "456 (Your Key)"])
      end

      it "returns an empty state message if there are no SSH keys" do
        allow(client_ssh_keys).to receive(:list).and_return(do_list_empty)
        send_command("do ssh keys list")
        expect(replies.last).to eq("No SSH keys have been added yet.")
      end
    end

    describe "#ssh_keys_show" do
      it "responds with the public key" do
        allow(client_ssh_keys).to receive(:show).with("123").and_return(do_key)
        send_command("do ssh keys show 123")
        expect(replies.last).to eq("123 (My Key): ssh-rsa abcdefg")
      end
    end
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
