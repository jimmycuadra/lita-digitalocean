require "spec_helper"

describe Lita::Handlers::Digitalocean::Image, lita_handler: true do
  it { routes_command("do images delete 123").to(:delete) }
  it { routes_command("do images list").to(:list) }
  it { routes_command("do images list filter").to(:list) }
  it { routes_command("do images show 123").to(:show) }

  let(:client) { instance_double("::DigitalOcean::API", images: client_images) }
  let(:client_images) { instance_double("::DigitalOcean::Resource::Image") }

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

    let(:do_delete) { { status: "OK" } }

  describe "#delete" do
    it "responds with a success message" do
      allow(client_images).to receive(:delete).with("123").and_return(do_delete)
      send_command("do images delete 123")
      expect(replies.last).to eq("Deleted image: 123")
    end
  end

  describe "#list" do
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

  describe "#show" do
    it "responds with the details of the image" do
      allow(client_images).to receive(:show).with("123").and_return(
        { status: "OK", image: public_image }
      )
      send_command("do images show 123")
      expect(replies.last).to eq(public_image_message)
    end
  end
end
