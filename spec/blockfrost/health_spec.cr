require "../spec_helper"

describe Blockfrost::Health do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches the health endpoint" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/health")
        .to_return(body: read_fixture("health/get.200.json"))

      Blockfrost::Health.get.tap do |health|
        health.is_healthy.should be_truthy
      end
    end
  end

  describe ".clock" do
    it "fetches the health server time endpoint" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/health/clock")
        .to_return(body: read_fixture("health/clock.200.json"))

      Blockfrost::Health.clock.tap do |health|
        health.server_time.should eq(Time.unix_ms(1603400958947))
      end
    end
  end
end
