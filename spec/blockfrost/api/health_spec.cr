require "../../spec_helper"

describe Blockfrost::Health do
  before_each do
    configure_api_keys
  end

  describe ".get" do
    it "fetches the health endpoint" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/health")
        .to_return(body: read_fixture("health/get.200.json"))

      Blockfrost::Health.get.is_healthy.should be_truthy
    end
  end

  describe ".is_healthy?" do
    it "fetches the actual health status" do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/health")
        .to_return(body: read_fixture("health/get.200.json"))

      Blockfrost::Health.is_healthy?.should be_truthy
    end
  end

  describe ".clock" do
    it "fetches the health clock endpoint" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/health/clock")
        .to_return(body: read_fixture("health/clock.200.json"))

      Blockfrost::Health.clock.server_time
        .should eq(Time.unix_ms(1603400958947))
    end
  end

  describe ".server_time" do
    it "returns the value of the clock endpoint" do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/health/clock")
        .to_return(body: read_fixture("health/clock.200.json"))

      Blockfrost::Health.server_time
        .should eq(Time.unix_ms(1603400958947))
    end
  end
end
