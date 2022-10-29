require "../../spec_helper"

describe Blockfrost::Metric do
  before_each do
    configure_api_keys
  end

  describe ".all" do
    it "fetches the metrics endpoint " do
      WebMock.stub(:get, "https://cardano-testnet.blockfrost.io/api/v0/metrics")
        .to_return(body_io: read_fixture("metric/all.200.json"))

      metric = Blockfrost::Metric.all.first
      metric.time.should eq(Time.unix(1612543884))
      metric.calls.should eq(42)
    end
  end

  describe ".endpoints" do
    it "fetches the metric endpoints endpoint " do
      WebMock.stub(:get,
        "https://cardano-testnet.blockfrost.io/api/v0/metrics/endpoints")
        .to_return(body_io: read_fixture("metric/endpoints.200.json"))

      metric = Blockfrost::Metric.endpoints.first
      metric.time.should eq(Time.unix(1612543814))
      metric.calls.should eq(182)
      metric.endpoint.should eq("block")
    end
  end
end
