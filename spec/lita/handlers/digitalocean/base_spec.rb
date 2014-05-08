require "spec_helper"

handler_class = Class.new(Lita::Handlers::Digitalocean::Base) do
  route /do droplets list/, :list, command: true

  def self.default_config(config)
  end

  def list(response)
    do_call(response) do |client|
      { status: "error", message: "Something went wrong" }
    end
  end
end

describe handler_class, lita_handler: true do
  describe "#do_call" do
    it "responds with an error if the DigitalOcean API key is not set" do
      send_command("do droplets list")
      expect(replies.last).to include("client_id and api_key must be set")
    end

    it "responds with an error if the DigitalOcean client ID is not set" do
      Lita.config.handlers.digitalocean.api_key = "secret"
      send_command("do droplets list")
      expect(replies.last).to include("client_id and api_key must be set")
    end

    it "responds with an error if the DigitalOcean API responds with an error" do
      Lita.config.handlers.digitalocean.tap do |config|
        config.api_key = "secret"
        config.client_id = "secret"
      end

      send_command("do droplets list")
      expect(replies.last).to eq("DigitalOcean API error: Something went wrong")
    end
  end
end
